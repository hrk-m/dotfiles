function fish_prompt
    if test -n "$SSH_TTY"
        echo -n (set_color F07178)"$USER"(set_color B3B1AD)'@'(set_color FFB454)(prompt_hostname)' '
    end

    echo -n (set_color 39BAE6)(prompt_pwd)' '

    # Git branch (detached HEAD is shown in a different color)
    if command -sq git; and command git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set -l branch_color C2D94C
        if not set -l branch (command git symbolic-ref --short HEAD 2>/dev/null)
            set branch_color D2A6FF
            set branch (command git describe --contains --all HEAD 2>/dev/null)
        end
        if test -n "$branch"
            echo -n (set_color -o $branch_color)"$branch"(set_color --reset)' '
        end
    end

    set_color -o
    if fish_is_root_user
        echo -n (set_color FF3333)'# '
    end
    echo -n (set_color F07178)'❯'(set_color FFB454)'❯'(set_color C2D94C)'❯ '
    set_color --reset
end
