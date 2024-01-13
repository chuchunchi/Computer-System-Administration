In this assignment, I have implement the freebsd version and ubuntu version.

1. Freebsd installation.

2. add user and judge.
    > User should also be in the "wheel" group ("sudo" on Ubuntu)
    > - Use this user to do this homework instead of root (using sudo)
    > - Add a user called "judge" for Online Judge
    > - User should also be in the "wheel" ("sudo" on ubuntu) group
    > - Please use "sh" as default shell (10%)
    > - This user needs to run sudo without password (15%)


    ```bash
    % visudo
    
    # add these lines
    # rubychi ALL=(ALL) ALL
    # judge   ALL=(ALL:ALL) NOPASSWD: ALL
    ```

3. enable sshd and install the public key fro online judge

4. Wireguard

    ```bash
    # install wireguard
    % sudo pkg install wireguard

    # cp config file to /usr/local/etc/wireguard/

    % wg-quick up wg0
    # Debug: ping -c 3 10.113.$ID.254
    ```