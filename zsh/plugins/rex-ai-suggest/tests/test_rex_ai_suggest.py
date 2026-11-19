"""Unit and integration tests for bin/rex-ai-suggest."""

from __future__ import annotations

import importlib.machinery
import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from unittest import mock

PLUGIN_DIR = Path(__file__).resolve().parent.parent
HELPER_PATH = PLUGIN_DIR / "bin" / "rex-ai-suggest"


def load_helper_module():
    loader = importlib.machinery.SourceFileLoader("rex_ai_suggest_mod", str(HELPER_PATH))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    assert spec is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[loader.name] = module
    loader.exec_module(module)
    return module


helper = load_helper_module()


class RedactionTests(unittest.TestCase):
    def test_redacts_common_tokens_and_keys(self):
        # Construct synthetic test fixtures dynamically so secret scanners never false-positive.
        google_key = "AIza" + "AbCdEfGhIjKlMnOpQrStUvWxYz123456"
        openai_key = "sk-proj-" + "1234567890abcdefghijklmnop"
        anthropic_key = "sk-ant-" + "api03-abcdefghijklmnopqrstuvwx"
        github_pat = "ghp_" + "1234567890abcdefghijklmnopqr"
        aws_key = "AKIA" + "IOSFODNN7EXAMPLE"
        jwt = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U"

        sample = "\n".join(
            [
                f"GOOGLE={google_key}",
                f"OPENAI={openai_key}",
                f"ANTHROPIC={anthropic_key}",
                f"GH={github_pat}",
                f"AWS={aws_key}",
                f"JWT={jwt}",
                "Authorization: Bearer super_secret_bearer_token_999",
                "DB_PASSWORD='my-super-secret-password'",
                "TOKEN=bare_token_value_123",
                '{"apiKey": "json_secret_value_456"}',
                'DATABASE_URL="postgres://admin:s3cr3tPass@db.internal:5432/prod"',
                "curl https://alice:wonderland@api.example.com/data --token secret_cli_tok",
                "-----BEGIN OPENSSH PRIVATE KEY-----\nAAAAB3NzaC1yc2EAAAADAQAB\n-----END OPENSSH PRIVATE KEY-----",
            ]
        )

        redacted = helper.redact_secrets(sample)

        for secret in (
            google_key,
            openai_key,
            anthropic_key,
            github_pat,
            aws_key,
            jwt,
            "super_secret_bearer_token_999",
            "my-super-secret-password",
            "bare_token_value_123",
            "json_secret_value_456",
            "s3cr3tPass",
            "wonderland",
            "secret_cli_tok",
            "AAAAB3NzaC1yc2EAAAADAQAB",
        ):
            self.assertNotIn(secret, redacted)

        self.assertIn("[REDACTED_PRIVATE_KEY]", redacted)
        self.assertIn("DB_PASSWORD=[REDACTED]", redacted)
        self.assertIn("TOKEN=[REDACTED]", redacted)
        self.assertIn('"apiKey": [REDACTED]', redacted)
        self.assertIn("DATABASE_URL=[REDACTED]", redacted)
        self.assertIn("https://[REDACTED]@api.example.com/data", redacted)
        self.assertIn("--token [REDACTED]", redacted)


class SensitiveCommandTests(unittest.TestCase):
    def test_detects_sensitive_commands(self):
        sensitive = [
            "cat .env",
            "cat .env.local",
            "printenv",
            "env",
            "export API_KEY=123",
            "veracrypt -t -d /Volumes/Dados/.data-hf",
            "aws configure",
            "kubectl get secret my-secret -o yaml",
            "op item get GitHub",
            "ssh-add ~/.ssh/id_ed25519",
        ]
        for cmd in sensitive:
            with self.subTest(cmd=cmd):
                self.assertTrue(helper.is_sensitive_command(cmd))

    def test_allows_normal_commands_unless_custom_pattern_matches(self):
        self.assertFalse(helper.is_sensitive_command("git status", extra_pattern=""))
        self.assertFalse(helper.is_sensitive_command("npm test", extra_pattern=""))
        self.assertTrue(
            helper.is_sensitive_command(
                "my-internal-deploy --prod", extra_pattern=r"\bmy-internal-deploy\b"
            )
        )


class ProactivePolicyTests(unittest.TestCase):
    def test_modes_and_trivial_filtering(self):
        self.assertEqual(
            helper.should_trigger_proactive("cd /tmp", 0, "smart"),
            (False, "trivial_command"),
        )
        self.assertEqual(
            helper.should_trigger_proactive("ls -la", 0, "smart"),
            (False, "trivial_command"),
        )
        self.assertEqual(
            helper.should_trigger_proactive("git status", 0, "smart"),
            (True, "high_signal_command"),
        )
        self.assertEqual(
            helper.should_trigger_proactive("date", 0, "smart"),
            (False, "low_signal_command"),
        )
        self.assertEqual(
            helper.should_trigger_proactive("date", 0, "all"),
            (True, "all_mode"),
        )
        self.assertEqual(
            helper.should_trigger_proactive("cd /missing", 1, "errors"),
            (True, "non_zero_exit"),
        )
        self.assertEqual(
            helper.should_trigger_proactive("git status", 0, "errors"),
            (False, "errors_only_mode"),
        )
        self.assertEqual(
            helper.should_trigger_proactive("git status", 0, "off"),
            (False, "proactive_off"),
        )
        self.assertEqual(
            helper.should_trigger_proactive("cat .env", 1, "smart"),
            (False, "sensitive_command"),
        )


class OptOutMarkerTests(unittest.TestCase):
    def test_detects_marker_in_cwd_and_ancestor(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            nested = root / "project" / "packages" / "web"
            nested.mkdir(parents=True)
            self.assertFalse(helper.has_opt_out_marker(str(nested)))

            (root / ".no-rex-ai").touch()
            self.assertTrue(helper.has_opt_out_marker(str(nested)))
            self.assertTrue(helper.has_opt_out_marker(str(root)))


class SanitizationTests(unittest.TestCase):
    def test_sanitizes_fences_prompts_multiline_and_blocks_destructive(self):
        self.assertEqual(
            helper.sanitize_suggestion("```zsh\n$ git diff --staged\necho hi\n```", "proactive"),
            "git diff --staged",
        )
        self.assertEqual(
            helper.sanitize_suggestion("`npm run build`", "manual"),
            "npm run build",
        )
        self.assertEqual(
            helper.sanitize_suggestion("NONE", "proactive"),
            "",
        )
        self.assertEqual(
            helper.sanitize_suggestion("git status", "proactive", last_cmd="git status", exit_code=0),
            "",
        )
        self.assertEqual(
            helper.sanitize_suggestion("git status", "proactive", last_cmd="git status", exit_code=1),
            "git status",
        )
        for dangerous in (
            "rm -rf /tmp/build",
            "rm -fr ./dist",
            "git push --force origin main",
            "git push origin main -f",
            "git reset --hard HEAD~1",
            "chmod -R 777 .",
            "mkfs.ext4 /dev/sdb",
            "dd if=/dev/zero of=/dev/disk2",
            "diskutil eraseDisk APFS Test disk2",
        ):
            with self.subTest(cmd=dangerous):
                self.assertEqual(helper.sanitize_suggestion(dangerous, "proactive"), "")


class EndToEndHttpAndCliTests(unittest.TestCase):
    def setUp(self):
        self.requests: list[dict] = []
        test_case = self

        class MockGeminiHandler(BaseHTTPRequestHandler):
            def do_POST(self):
                length = int(self.headers.get("Content-Length", "0"))
                raw = self.rfile.read(length).decode("utf-8")
                test_case.requests.append(
                    {
                        "path": self.path,
                        "headers": {k.lower(): v for k, v in self.headers.items()},
                        "body": json.loads(raw),
                    }
                )
                resp = {
                    "candidates": [
                        {
                            "content": {
                                "parts": [
                                    {"thought": True, "text": "internal thought"},
                                    {"text": "```bash\ngit commit -m 'fix'\n```"},
                                ]
                            }
                        }
                    ]
                }
                encoded = json.dumps(resp).encode("utf-8")
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(encoded)))
                self.end_headers()
                self.wfile.write(encoded)

            def log_message(self, format, *args):
                pass

        self.server = HTTPServer(("127.0.0.1", 0), MockGeminiHandler)
        self.port = self.server.server_address[1]
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()

    def test_http_header_auth_and_thinking_config(self):
        base_url = f"http://127.0.0.1:{self.port}/v1beta"
        fake_key = "test-api-key-value-123"

        env = os.environ.copy()
        env["GEMINI_API_KEY"] = fake_key
        env["REX_AI_API_BASE_URL"] = base_url
        env["REX_AI_MODEL"] = "gemini-3.5-flash-lite"

        proc = subprocess.run(
            [
                str(HELPER_PATH),
                "--mode=proactive",
                "--no-capture",
                "--last-cmd=git add .",
                "--exit-code=0",
            ],
            env=env,
            capture_output=True,
            text=True,
            check=True,
        )
        self.assertEqual(proc.stdout, "git commit -m 'fix'")
        self.assertEqual(len(self.requests), 1)
        req = self.requests[0]
        self.assertEqual(req["path"], "/v1beta/models/gemini-3.5-flash-lite:generateContent")
        self.assertNotIn("key=", req["path"])
        self.assertEqual(req["headers"].get("x-goog-api-key"), fake_key)
        self.assertEqual(
            req["body"]["generationConfig"]["thinkingConfig"],
            {"thinkingLevel": "MINIMAL"},
        )

        # Also verify gemini-2.5 thinkingBudget=0
        payload_25 = helper.build_gemini_payload(
            mode="proactive",
            model="gemini-2.5-flash-lite",
            cwd="/tmp",
            last_cmd="git status",
            exit_code=0,
            buffer="",
            history="",
            terminal_output="",
        )
        self.assertEqual(
            payload_25["generationConfig"]["thinkingConfig"],
            {"thinkingBudget": 0},
        )

    def test_dry_run_redacts_capture_and_makes_zero_http_calls(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            fake_rex = Path(tmpdir) / "rex"
            fake_token = "ghp_" + "9876543210zyxwvutsrqponm"
            fake_rex.write_text(
                f"#!/bin/sh\necho 'error: auth failed for {fake_token}'\n",
                encoding="utf-8",
            )
            fake_rex.chmod(0o755)

            env = os.environ.copy()
            env["REX_AI_REX_BIN"] = str(fake_rex)
            env["REX_AI_API_BASE_URL"] = f"http://127.0.0.1:{self.port}/v1beta"
            env["GEMINI_API_KEY"] = "should-not-be-sent-in-dry-run"

            proc = subprocess.run(
                [
                    str(HELPER_PATH),
                    "--dry-run",
                    "--mode=proactive",
                    "--cwd",
                    tmpdir,
                    "--last-cmd=git push",
                    "--exit-code=1",
                    "--block=blk-test",
                ],
                env=env,
                capture_output=True,
                text=True,
                check=True,
            )
            data = json.loads(proc.stdout)
            self.assertTrue(data["triggered"])
            self.assertFalse(data["capture_skipped"])
            user_text = data["payload"]["contents"][0]["parts"][0]["text"]
            self.assertNotIn(fake_token, user_text)
            self.assertIn("[REDACTED_GITHUB_TOKEN]", user_text)
            self.assertEqual(len(self.requests), 0)

    def test_status_never_prints_api_key(self):
        secret = "AIza" + "SecretShouldNeverAppearInStatus123"
        with mock.patch.dict(os.environ, {"GEMINI_API_KEY": secret}, clear=False):
            out = helper.format_status("/tmp", "blk-1")
            self.assertIn("configured (GEMINI_API_KEY)", out)
            self.assertNotIn(secret, out)


if __name__ == "__main__":
    unittest.main()
