#
#
#           The Nim Compiler
#        (c) Copyright 2018 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## This module implements helpers for the macro cache.

import lineinfos, ast, modulegraphs, vmdef, magicsys

proc genCall3(g: ModuleGraph; m: TMagic; s: string; a, b, c: PNode): PNode =
  newTree(nkStaticStmt, newTree(nkCall, createMagic(g, s, m).newSymNode, a, b, c))

proc genCall2(g: ModuleGraph; m: TMagic; s: string; a, b: PNode): PNode =
  newTree(nkStaticStmt, newTree(nkCall, createMagic(g, s, m).newSymNode, a, b))

template nodeFrom(s: string): PNode =
  var res = newStrNode(s, info)
  res.typ = getSysType(g, info, tyString)
  res

template nodeFrom(i: BiggestInt): PNode =
  var res = newIntNode(i, info)
  res.typ = getSysType(g, info, tyInt)
  res

template nodeFrom(n: PNode): PNode = copyTree(n)

template record(call) =
  g.recordStmt(g, c.module, call)

proc recordInc*(c: PCtx; info: TLineInfo; key: string; by: BiggestInt) =
  let g = c.graph
  record genCall2(mNccInc, "inc", nodeFrom key, nodeFrom by)

proc recordPut*(c: PCtx; info: TLineInfo; key: string; k: string; val: PNode) =
  let g = c.graph
  record genCall3(mNctPut, "[]=", nodeFrom key, nodeFrom k, nodeFrom val)

proc recordAdd*(c: PCtx; info: TLineInfo; key: string; val: PNode) =
  let g = c.graph
  record genCall2(mNcsAdd, "add", nodeFrom key, nodeFrom val)

proc recordIncl*(c: PCtx; info: TLineInfo; key: string; val: PNode) =
  let g = c.graph
  record genCall2(mNcsIncl, "incl", nodeFrom key, nodeFrom val)
