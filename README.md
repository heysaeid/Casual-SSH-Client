# Casual-SSH-Client
For casual use 	😀

## Usage


### Install tmux</br>
Install [tmux](https://github.com/tmux/tmux/wiki/Installing) according to your operating system


### Grant execute access
```shell
shell chmod +x casual.sh
```


### Add session
```shell
casual add
```

### Edit session
```shell
s casual edit
```


### Remove session
```shell 
casual remove
```


### View the list of sessions
```shell
casual ls
```


### SSH
```shell
casual ssh session_name1,session_name2,session_name2
```

If needed, synchronize-panes mode</br>
```shell
 casual ssh session_name1,session_name2,session_name2 sync
```
