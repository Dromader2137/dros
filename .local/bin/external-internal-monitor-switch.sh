#!/bin/bash

get_monitors() {
    hyprctl monitors -j | jq -r '.[].name'
}

get_connected_monitors() {
    hyprctl monitors -j | jq -r '.[].name'
}

is_monitor_enabled() {
    local monitor=$1
    hyprctl monitors -j | jq -e --arg name "$monitor" '.[] | select(.name == $name)' > /dev/null 2>&1
    return $?
}

get_internal_monitor() {
    hyprctl monitors all -j | jq -r '.[] | select(.name | test("^eDP-[0-9]+$")) | .name' | head -n 1
}

get_external_monitors() {
    hyprctl monitors all -j | jq -r '.[] | select(.name | test("^eDP-[0-9]+$") | not) | .name'
}

has_external_monitors() {
    local external_count=$(hyprctl monitors all -j | jq '[.[] | select(.name | test("^eDP-[0-9]+$") | not)] | length')
    [ "$external_count" -gt 0 ]
}

main() {
    local internal_monitor=$(get_internal_monitor)
    
    if [ -z "$internal_monitor" ]; then
        echo "No internal monitor detected. This script is designed for laptops."
        exit 1
    fi
    
    echo "Internal monitor: $internal_monitor"
    
    if has_external_monitors; then
        echo "External monitor(s) detected:"
        get_external_monitors
        
        echo "Disabling internal monitor..."
        hyprctl keyword monitor "$internal_monitor,disable"
        
        for monitor in $(get_external_monitors); do
            echo "Enabling external monitor: $monitor"
            hyprctl keyword monitor "$monitor,preferred,auto,1"
        done
    else
        echo "No external monitors detected."
        
        if ! is_monitor_enabled "$internal_monitor"; then
            echo "Re-enabling internal monitor..."
            hyprctl keyword monitor "$internal_monitor,preferred,auto,1"
        else
            echo "Internal monitor is already enabled."
        fi
        
        for monitor in $(get_external_monitors); do
            echo "Disabling external monitor: $monitor"
            hyprctl keyword monitor "$monitor,disable"
        done
    fi
}

main
