; Disable error song and put a visible bell instead
(setq ring-bell-function 'ignore
      visible-bell t)

 ; Enable Nerd Font
(set-frame-font "MesloLGLDZ Nerd Font Mono 18" nil)

; Improve the readbility with line-spacing 0.6
(setq-default line-space 0.6)

(provide 'core)
