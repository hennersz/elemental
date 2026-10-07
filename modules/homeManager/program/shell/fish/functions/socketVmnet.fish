function socketVmnet -d "Start or stop the socket_vmnet launchd service used for local VMs"
    set -l plist /Library/LaunchDaemons/sh.brew.socket_vmnet.plist
    set -l label system/sh.brew.socket_vmnet

    switch "$argv[1]"
        case start
            sudo launchctl bootstrap system $plist
        case stop
            sudo launchctl bootout $label
        case '*'
            echo "Usage: socketVmnet start|stop"
            return 1
    end
end
