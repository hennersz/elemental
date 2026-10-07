function warpFixDns -d "Stop services that block Cloudflare WARP's port 53 bind, connect WARP, then restore those services"
    set -l blockers system/org.nixos.linux-builder system/sh.brew.socket_vmnet system/com.docker.vmnetd

    echo "Stopping services that may block WARP's DNS bind..."
    for s in $blockers
        sudo launchctl bootout $s 2>/dev/null
    end

    sudo killall -HUP mDNSResponder

    echo "Connecting WARP..."
    warp-cli connect >/dev/null

    set -l connected 0
    for i in (seq 1 15)
        if warp-cli status | string match -q '*Connected*'
            set connected 1
            break
        end
        sleep 1
    end

    if test $connected -eq 0
        echo "WARP did not connect - leaving blockers stopped. Check 'warp-cli status', then rerun warpFixDns once fixed to restore them."
        return 1
    end

    echo "WARP connected. Restoring services..."
    sudo launchctl bootstrap system /Library/LaunchDaemons/org.nixos.linux-builder.plist 2>/dev/null
    sudo launchctl bootstrap system /Library/LaunchDaemons/sh.brew.socket_vmnet.plist 2>/dev/null
    sudo launchctl bootstrap system /Library/LaunchDaemons/com.docker.vmnetd.plist 2>/dev/null
    echo "Done."
end
