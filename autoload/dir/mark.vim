vim9script

var mark_list: list<dict<any>> = []
var mark_dir: string = ""
var mark_bufnr: number = -1

prop_type_add('DirMark', {highlight: 'DirMark', priority: 1000})


def OtherDirBuffers(): list<dict<any>>
    return getbufinfo()->filter((_, v) => v.name =~ '^dir://' && bufnr() != v.bufnr)
enddef


def ClearOtherBufferMarks()
    for buf_info in OtherDirBuffers()
        prop_clear(1, buf_info.linecount, {type: 'DirMark', bufnr: buf_info.bufnr})
        UpdateInfo(buf_info.bufnr)
    endfor
enddef


export def List(): list<dict<any>>
    return mark_list
enddef


export def Dir(): string
    return mark_dir
enddef


export def Bufnr(): number
    return mark_bufnr
enddef


export def UpdateInfo(bufnr: number = -1)
    var nr = (bufnr == -1 ? bufnr() : bufnr)
    setbufvar(nr, '&modifiable', 1)
    setbufvar(nr, '&readonly', 0)
    var cnt = mark_list->len()
    if cnt > 0
        setbufline(nr, 2, $"Selected: {cnt}")
    else
        setbufline(nr, 2, "")
    endif
    setbufvar(nr, '&modified', 0)
    setbufvar(nr, '&modifiable', 0)
    setbufvar(nr, '&readonly', 1)
    # setl noma nomod ro
enddef


export def Toggle(items: list<dict<any>>, line1: number, line2: number)
    if bufnr() != mark_bufnr
        Clear()
    endif
    for el in items
        var idx = mark_list->index(el)
        if idx != -1
            mark_list->remove(idx)
        else
            mark_list->add(el)
        endif
    endfor
    mark_dir = b:dir_cwd
    mark_bufnr = bufnr()

    UpdateInfo()

    for line in range(min([line1, line2]), max([line1, line2]))
        if empty(prop_list(line, {types: ['DirMark']}))
            prop_add(line, 1, {type: 'DirMark', length: getline(line)->len()})
        else
            prop_clear(line, line, {type: 'DirMark'})
        endif
    endfor
enddef


export def Clear()
    mark_list = []
    mark_dir = ""
    mark_bufnr = -1
    prop_clear(1, line('$'), {type: 'DirMark'})
    ClearOtherBufferMarks()
    UpdateInfo()
enddef


export def DebugPrint()
    echo mark_list->mapnew((_, v) => $"[{v.type}]\t{v.name}")->join("\n")
    echo $"count: {mark_list->len()}"
    echo $"Mark Dir: {mark_dir}"
    echo $"Mark Buffer: {mark_bufnr}"
enddef


export def Empty(): bool
    return len(mark_list) == 0
enddef
