import strutils, strmisc

type
    Instruction* = object
        match: string
        replace: string
        match_extra: uint32

    InstructionSet* = object
        instructions: seq[Instruction]

    Source* = ref object
        instructionsets: seq[InstructionSet]

proc compile*(src: string): Source =
    new result
    result.instructionsets = newSeq[InstructionSet]()
    var tmp = newSeq[Instruction]()

    for lines in src.splitLines(false):
        if lines.isEmptyOrWhitespace():
            if tmp.len == 0:
                continue
            result.instructionsets.add(InstructionSet(instructions: tmp))
            tmp = newSeq[Instruction]()

        if not lines.contains("="):
            continue

        let (match, _, replace) = lines.partition("=")
        tmp.add(Instruction(match: match, replace: replace, match_extra: 0))

    if tmp.len > 0:
        result.instructionsets.add(InstructionSet(instructions: tmp))

proc execute(inst: Instruction, input: string): (string, bool) =
    if inst.match_extra == 0:
        let match = input.find(inst.match)

        if match == -1:
            return (input, false)

        let (head, _, tail) = input.partition(inst.match)

        return (head & inst.replace & tail, true)
    else:
        var err = new LibraryError
        err.msg = "not implemented"
        raise err

proc execute(iset: InstructionSet, input: string): (string, bool) =
    var input = input
    var change = false
    var change_once = false

    while true:
        for inst in iset.instructions:
            (input, change) = inst.execute(input)

            if change:
                change_once = true
                break
        if not change:
            break

    return (input, change_once)

proc execute*(src: Source, input: string): (string, bool) =
    var input = input
    var change = false
    var change_once = false

    while true:
        for iset in src.instructionsets:
            (input, change) = iset.execute(input)

            if change:
                change_once = true
                break

        if not change:
            break

    return (input, change_once)
