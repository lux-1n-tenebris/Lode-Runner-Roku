' ********************************************************************************************************
' ********************************************************************************************************
' **  Roku Lode Runner Channel - http://github.com/lvcabral/Lode-Runner-Roku
' **
' **  libCanvas.brs - Library to implement generic Canvas object
' **  Created: June 2018
' **  Updated: July 2019
' **
' **  Copyright (C) Marcelo Lv Cabral < https://lvcabral.com >
' ********************************************************************************************************
' ********************************************************************************************************

Function CreateMessageDialog() as object
    ' Objects
    this = {buttons:[], canvas: GetTopCanvas()}
    this.screen = this.canvas.screen
    this.codes = m.code
    this.sounds = m.sounds
    this.theme = m.theme
    this.titleFont = this.canvas.fonts.reg.GetDefaultFont(32, true, false)
    this.textFont =  this.canvas.fonts.reg.GetDefaultFont(25, false, false)

    this.dialogTitle = ""
    this.dialogText = ""
    this.focus = 0
    this.overlay = false
    this.visible = false
    this.backCache = false
    this.lineHeight = this.textFont.GetOneLineHeight()

    ' Methods
    this.SetMessagePort = set_msg_port
    this.SetTitle = set_dialog_title
    this.SetText = set_dialog_text
    this.AddButton = add_button
    this.EnableOverlay = enable_overlay
    this.SetFocusedMenuItem = set_focused_item
    this.Show = show_msg_dialog
    this.Wait = wait_msg_dialog

    return this
End Function

Sub show_msg_dialog()
    print "Show Dialog"
    txtArray = []
    imgArray = []
    imgArray.Push({ url: "pkg:/images/dialog-top.png"
                    TargetRect: {x:254, y:171}})
    imgArray.Push({ url: "tmp:/dialog-back.png"
                    TargetRect: {x:254, y:203}})
    txtArray.Push({
                Text: m.dialogTitle
                TextAttrs: {color: "#4F5962FF", font: m.titleFont, HAlign: "Center"}
                TargetRect: {x:275, y:208, w:730, h:32}})
    lines = m.dialogText.Split(Chr(10))
    textHeight = m.lineHeight * lines.Count()
    for l = 0 to lines.Count() - 1
        txtArray.Push({
                    Text: lines[l]
                    TextAttrs: {color: "#666D70FF", font: m.textFont, HAlign: "Left"}
                    TargetRect: {x:294, y:260 + (l * m.lineHeight), w:680, h:m.lineHeight}})
    next
    menuPos = {x: 290, y: 280 + (l * m.lineHeight)}
    if m.buttons.Count() > 0
        for i = 0 to m.buttons.Count() - 1
            if i = m.focus
                imgArray.Push({ url: "pkg:/images/dialog-bar.png"
                                TargetRect: {x:menuPos.x , y:menuPos.y}})
                textColor = m.theme.ListItemHighlightText
            else
                imgArray.Push({ url: "pkg:/images/dialog-menu.png"
                                TargetRect: {x:952 , y:menuPos.y}})
                textColor = "#666D70FF"
            end if
            txtArray.Push({
                        Text: m.buttons[i].text
                        TextAttrs: {color: textColor, font: m.textFont, HAlign: "Right"}
                        TargetRect: {x:menuPos.x + 28, y:menuPos.y + 2, w:622, h:30}})
            menuPos.y = menuPos.y + 36
        next
    end if
    if not m.backCache
        bmp = ScaleToSize(CreateObject("roBitmap", "pkg:/images/dialog-back.png"), 771, menuPos.y-203, false)
        png = bmp.GetPng(0, 0, bmp.GetWidth(), bmp.GetHeight())
        png.WriteFile("tmp:/dialog-back.png")
        m.backCache = true
    end if
    imgArray.Push({ url: "pkg:/images/dialog-bottom.png"
                    TargetRect: {x:254, y:menuPos.y}})
    m.canvas.SetLayer(91, imgArray)
    m.canvas.SetLayer(92, txtArray)
    m.canvas.Show()
    m.visible = true
End Sub

Function wait_msg_dialog(port) as object
    if port = invalid then port = m.canvas.screen.port
    while true
        event = wait(0, port)
        if type(event) = "roUniversalControlEvent"
            index = event.GetInt()
            if index = m.codes.BUTTON_UP_PRESSED
                if m.buttons.Count() > 0
                    if m.focus = 0
                        m.sounds.dead.Trigger(50)
                    else
                        m.focus--
                        m.sounds.navSingle.Trigger(50)
                        m.Show()
                    end if
                end if
            else if index = m.codes.BUTTON_DOWN_PRESSED
                if m.buttons.Count() > 0
                    if m.focus = m.buttons.Count() - 1
                        m.sounds.dead.Trigger(50)
                    else
                        m.focus++
                        m.sounds.navSingle.Trigger(50)
                        m.Show()
                    end if
                end if
            else if index = m.codes.BUTTON_BACK_PRESSED
                m.sounds.navSingle.Trigger(50)
                msg = GetScreenMessage(m.focus, "closed")
                exit while
            else if index = m.codes.BUTTON_SELECT_PRESSED
                m.sounds.select.Trigger(50)
                msg = GetScreenMessage(m.buttons[m.focus].id, "button")
                exit while
            end if
        end if
    end while
    m.canvas.ClearLayer(91)
    m.canvas.ClearLayer(92)
    m.canvas.Show()
    return msg
End Function

Sub set_dialog_title(title as string)
    m.dialogTitle = title   
End Sub

Sub set_dialog_text(text as string)
    m.dialogText = text
End Sub

Sub add_button(id as integer, text as string)
    m.buttons.Push({id: id, text: text})
End Sub

Sub enable_overlay(enable as boolean)
    m.overlay = enable
End Sub
