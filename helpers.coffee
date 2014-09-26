###
# Usefull utils
# Copied and modified from StackOverflow
#
# Modified by: RedDec <net.dev@mail.ru>
# 25 Sep 2014
###
"use strict"

ab2str=(buf)-> String.fromCharCode.apply null, new Uint16Array(buf)

ab2str8=(buf)-> String.fromCharCode.apply null, new Uint8Array(buf)

str2ab=(str)->
  buf = new ArrayBuffer(str.length*2)
  bufView = new Uint16Array(buf)
  for a, i in str
    bufView[i] = str.charCodeAt(i)
  return buf
