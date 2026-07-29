function fish_prompt
    if test -n "$SSH_TTY"
        echo -n (set_color F07178)"$USER"(set_color B3B1AD)'@'(set_color FFB454)(prompt_hostname)' '
    end

    echo -n (set_color 39BAE6)(prompt_pwd)' '

    set_color -o
    if fish_is_root_user
        echo -n (set_color FF3333)'# '
    end
    echo -n (set_color F07178)'❯'(set_color FFB454)'❯'(set_color C2D94C)'❯ '
    set_color --reset
end
