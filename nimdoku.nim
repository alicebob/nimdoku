import karax / [vdom, karax, karaxdsl, kdom]

type
  CellKind = enum
    empty,
    clue,
    answer
  Cell = ref CellObj
  CellObj = object
    case kind: CellKind
    of empty: bogus: int
    of clue: clue: range[1..9]
    of answer: answer: range[1..9]
  Board = array[0..9*9, Cell]

proc cell(row: int, col: int): int = 
    result = row * 9 + col

proc createBoard(): Board =
    var board:Board;
    for i in 0..9*9:
        board[i] = Cell(kind: empty)
    board[cell(0, 0)] = Cell(kind: clue, clue:5)
    board[cell(0, 1)] = Cell(kind: clue, clue:3)
    board[cell(0, 4)] = Cell(kind: clue, clue:7)
    board[cell(1, 0)] = Cell(kind: clue, clue:6)
    board[cell(1, 3)] = Cell(kind: clue, clue:1)
    board[cell(1, 4)] = Cell(kind: clue, clue:9)
    board[cell(1, 5)] = Cell(kind: clue, clue:5)
    board[cell(2, 1)] = Cell(kind: clue, clue:9)
    board[cell(2, 2)] = Cell(kind: clue, clue:8)
    board[cell(2, 7)] = Cell(kind: clue, clue:6)
    board[cell(3, 0)] = Cell(kind: clue, clue:8)
    board[cell(3, 4)] = Cell(kind: clue, clue:6)
    board[cell(3, 8)] = Cell(kind: clue, clue:3)
    board[cell(4, 0)] = Cell(kind: clue, clue:4)
    board[cell(4, 3)] = Cell(kind: clue, clue:8)
    board[cell(4, 5)] = Cell(kind: clue, clue:3)
    board[cell(4, 8)] = Cell(kind: clue, clue:1)
    board[cell(5, 0)] = Cell(kind: clue, clue:7)
    board[cell(5, 4)] = Cell(kind: clue, clue:2)
    board[cell(5, 8)] = Cell(kind: clue, clue:6)
    board[cell(6, 1)] = Cell(kind: clue, clue:6)
    board[cell(6, 6)] = Cell(kind: clue, clue:2)
    board[cell(6, 7)] = Cell(kind: clue, clue:8)
    board[cell(7, 3)] = Cell(kind: clue, clue:4)
    board[cell(7, 4)] = Cell(kind: clue, clue:1)
    board[cell(7, 5)] = Cell(kind: clue, clue:9)
    board[cell(7, 8)] = Cell(kind: clue, clue:5)
    board[cell(8, 4)] = Cell(kind: clue, clue:8)
    board[cell(8, 7)] = Cell(kind: clue, clue:7)
    board[cell(8, 8)] = Cell(kind: clue, clue:9)
    result = board

var board = createBoard()
var selected : int = 0

proc renderCell(id:int, c: Cell): VNode =
    var onclick = proc() =
        selected = id

    var value:VNode
    if c == nil:
        ## FIXME: no nil values
        value = text "x"
    else:
        case c.kind
        of empty:
            value = text ""
        of clue:
            value = buildHtml(tdiv(class="clue")):
                text $c.clue
            onclick = proc() =
                var bogus:int = 1
                bogus += 1
        of answer:
            value = text $c.answer

    var class = "cell"
    if selected == id:
        class &= " selected"
    result = buildHtml(tdiv(class=class, onclick=onclick)):
        value

proc setup() =
    let x = document.getElementById("body")
    proc onkeynat(): NativeEventHandler =
        result = proc (ev: Event) =
            var code = cast[KeyboardEvent](ev).keyCode
            case code
            of 37: # left
                if selected mod 9 != 0:
                    selected -= 1
            of 38: # up
                if selected > 8:
                    selected -= 9
            of 39: # right
                if selected mod 9 != 8:
                    selected += 1
            of 40: # down
                if selected < 8*9:
                    selected += 9
            else:
                code -= 48 # That's key '1'...
                if code >= 0 and code <= 9:
                    var sel = board[selected]
                    case sel.kind
                    of clue:
                        var bogus = 1
                        bogus += 1
                    of answer:
                        sel.answer = code
                    of empty:
                        sel.kind = answer
                        sel.answer = code
            redraw()
    document.body.addEventListener("keydown", onkeynat())

proc createDom(): VNode =
    result = buildHtml(tdiv()):
        text "hello world"
        br()
        tdiv(class="board"):
            for row in 0..8:
                tdiv(class="row"):
                    for col in 0..8:
                        renderCell(cell(row, col), board[cell(row, col)])
        br()
        text "done"


setup()
setRenderer createDom
