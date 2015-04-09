'use strict';

chrome.runtime.onInstalled.addListener (details) ->

Stat =
  data: {}
  cur: null

tabChanged = (url) ->
  if Stat.cur
    lst = Stat.data[Stat.cur]
    lst.push(new Date())
  Stat.cur = url
  lst = Stat.data[url] or []
  lst.push(new Date())
  Stat.data[url] = lst
  return Stat.data[url]

calc = (url)->
  lst = Stat.data[url]
  if not lst
    return 0
  n = Math.floor (lst.length / 2)
  res = 0
  for i in [0..n]
    if lst[2 * i + 1] and lst[2 * i]
      res += lst[2 * i + 1].getTime() - lst[2 * i].getTime()
  res += (new Date()).getTime() - lst[lst.length - 1].getTime()
  return res

updateBadge = (url,sec)->
  if (sec>0)
    res = parseInt(sec)
    res +=1
    s = res % 60
    m = Math.floor (res / 60) % 60
    h = Math.floor (res / 3600) % 24
    chrome.browserAction.setBadgeText({text: "#{m}:#{s}"})

  else
    res = calc url
    s = Math.floor(res / 1000) % 60
    m = Math.floor(res / 60000) % 60
    h = Math.floor(res / 3600000) % 24
    chrome.browserAction.setBadgeText({text: "#{m}:#{s}"})
    
  localStorage.setItem(url,res)

 

getDomain = (url) ->
  myDomain = document.createElement "a"
  myDomain.href = url
  console.log "domain = "+ myDomain.hostname
  return myDomain.hostname

# isNecessaryProtocol = (url) ->
#   urlProtocol = document.createElement "a"
#   urlProtocol.href = url
#   if (urlProtocol.protocol == "http:" || urlProtocol.protocol == "https:")
#     return true
#   else 
#     return false


chrome.tabs.onActivated.addListener (activeInfo)->
  Stat.curTabId = activeInfo.tabId
  chrome.tabs.get activeInfo.tabId, (tab) ->
    myDomain = document.createElement "a"
    myDomain.href = tab.url
    if (myDomain.protocol == "http:" || myDomain.protocol == "https:")
      console.log "prowel proverku"
      domain = getDomain tab.url 
      tabChanged(domain) if domain
      updateBadge domain, localStorage.getItem(domain)


timer = () ->
  if not Stat.curTabId
      return
    chrome.tabs.get Stat.curTabId, (tab)->
      domain = getDomain tab.url 
      if domain
        updateBadge domain,localStorage.getItem(domain)



setInterval(timer, 1000)