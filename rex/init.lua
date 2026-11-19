local function run_in_terminal(ctx, cmd)
    local params = { data = cmd .. "\r" }
    if ctx and ctx.block_id and ctx.block_id ~= "" then
        params.block_id = ctx.block_id
    end
    rex.block.call("com.superlogical.terminal", "write", params)
end

local function has_ui_input()
    return rex.ui ~= nil and rex.ui.input ~= nil
end

local function has_ui_pick()
    return rex.ui ~= nil and rex.ui.pick ~= nil
end

-- 1. unmount encrypt (Warp alias: unmount-data-hf)
rex.action {
    name = "unmount_data_hf",
    title = "Unmount Encrypt (unmount-data-hf)",
    description = "Desmonta o volume criptografado /Volumes/Dados/.data-hf",
    category = "Workflows",
    run = function(ctx, args)
        run_in_terminal(ctx, 'veracrypt -t --force -d "/Volumes/Dados/.data-hf"')
    end,
}

-- 2. mount encrypt (Warp alias: mount-data-hf)
rex.action {
    name = "mount_data_hf",
    title = "Mount Encrypt (mount-data-hf)",
    description = "Monta o volume criptografado /Volumes/Dados/.data-hf em ~/Volumes/data-hf",
    category = "Workflows",
    run = function(ctx, args)
        run_in_terminal(
            ctx,
            'env OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES veracrypt -t -k "" --protect-hidden=no "/Volumes/Dados/.data-hf" ~/Volumes/data-hf'
        )
    end,
}

-- 3. download_video (Warp alias: download-video)
rex.action {
    name = "download_video",
    title = "Download Video (download-video)",
    description = "Baixa um vídeo em MP4 usando yt-dlp",
    category = "Workflows",
    args = {
        file_name = "string?",
        video_url = "string?",
    },
    run = function(ctx, args)
        local file_name = args and args.file_name or nil
        local video_url = args and args.video_url or nil

        if (not file_name or file_name == "") or (not video_url or video_url == "") then
            if has_ui_input() then
                if not file_name or file_name == "" then
                    file_name = rex.ui.input {
                        title = "Nome do arquivo (sem .mp4)",
                        placeholder = "meu_video",
                        confirm = "Próximo",
                    }
                    if not file_name or file_name == "" then return end
                end
                if not video_url or video_url == "" then
                    video_url = rex.ui.input {
                        title = "URL do vídeo",
                        placeholder = "https://...",
                        confirm = "Baixar vídeo",
                    }
                    if not video_url or video_url == "" then return end
                end
            else
                run_in_terminal(ctx, "~/.config/rex/scripts/download-video.sh")
                return
            end
        end

        run_in_terminal(ctx, 'yt-dlp -o "' .. file_name .. '.mp4" "' .. video_url .. '"')
    end,
}

-- 4. download_blob
rex.action {
    name = "download_blob",
    title = "Download Blob (download-blob)",
    description = "Baixa stream HLS 1080p usando yt-dlp com headers customizados",
    category = "Workflows",
    args = {
        file_name = "string?",
        video_url = "string?",
    },
    run = function(ctx, args)
        local file_name = args and args.file_name or nil
        local video_url = args and args.video_url or nil

        if (not file_name or file_name == "") or (not video_url or video_url == "") then
            if has_ui_input() then
                if not file_name or file_name == "" then
                    file_name = rex.ui.input {
                        title = "Nome do arquivo (sem .mp4)",
                        placeholder = "meu_video",
                        confirm = "Próximo",
                    }
                    if not file_name or file_name == "" then return end
                end
                if not video_url or video_url == "" then
                    video_url = rex.ui.input {
                        title = "URL base do vídeo (prefixo antes de _Ott_Hls_...)",
                        placeholder = "https://...",
                        confirm = "Baixar blob",
                    }
                    if not video_url or video_url == "" then return end
                end
            else
                run_in_terminal(ctx, "~/.config/rex/scripts/download-blob.sh")
                return
            end
        end

        local cmd = 'yt-dlp -o "' .. file_name .. '.mp4" "' .. video_url
            .. '_Ott_Hls_Ts_Avc_Aac_1080p_4Mbps_qvbr.m3u8" '
            .. '--referer "https://privacy.com.br/" '
            .. '--add-header "Origin: https://privacy.com.br" '
            .. '--user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:156.0) Gecko/20100101 Firefox/156.0"'

        run_in_terminal(ctx, cmd)
    end,
}

-- 5. Connect EC2 (via ~/.ssh/config)
rex.action {
    name = "connect_ec2",
    title = "Connect EC2 (connect-ec2)",
    description = "Conecta via SSH a uma instância EC2 configurada em ~/.ssh/config",
    category = "Workflows",
    args = {
        env = "string?",
    },
    run = function(ctx, args)
        local env = args and args.env or nil

        if not env or env == "" then
            if has_ui_pick() then
                env = rex.ui.pick {
                    title = "Conectar EC2",
                    placeholder = "Escolha o ambiente…",
                    items = {
                        { id = "synter-prod", title = "synter-prod", subtitle = "Synter Production (~/.ssh/synter-production.pem)" },
                        { id = "synter-staging", title = "synter-staging", subtitle = "Synter Staging (~/.ssh/synter-staging.pem)" },
                        { id = "crabki-prod", title = "crabki-prod", subtitle = "Crabki Production (~/.ssh/crabki-production.pem)" },
                        { id = "crabki-staging", title = "crabki-staging", subtitle = "Crabki Staging (~/.ssh/crabki-staging.pem)" },
                    },
                }
                if not env or env == "" then return end
            else
                run_in_terminal(ctx, "~/.config/rex/scripts/connect-ec2.sh")
                return
            end
        end

        run_in_terminal(ctx, "ssh " .. env)
    end,
}
