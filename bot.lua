package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
.. ';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

---- @AnonySecurity
http = require("socket.http")
https = require("ssl.https")
http.TIMEOUT = 10
JSON = require('dkjson')
--------- @AnonySecurity
tdcli = dofile('tdcli.lua')
redis = (loadfile "./libs/redis.lua")()
serpent = require('serpent')
serp = require 'serpent'.block
sudo_users = {
    133362226,
	324656723,
}

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c)
    fields[#fields + 1] = c
  end)
  return fields
end

function is_sudo(msg)
  local var = false
  for v,user in pairs(sudo_users) do
    if user == msg.sender_user_id_ then
      var = true
    end
  end
  return var
end

function is_normal(msg)
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  local mutel = redis:sismember('muteusers:'..chat_id,user_id)
  if mutel then
    return true
  end
  if not mutel then
    return false
  end
end
-- function owner
function is_owner(msg)
  local var = false
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  local group_mods = redis:get('owners:'..chat_id)
  if group_mods == tostring(user_id) then
    var = true
  end
  for v, user in pairs(sudo_users) do
    if user == user_id then
      var = true
    end
  end
  return var
end
--- function promote
function is_mod(msg)
  local var = false
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  if redis:sismember('mods:'..chat_id,user_id) then
    var = true
  end
  if  redis:get('owners:'..chat_id) == tostring(user_id) then
    var = true
  end
  for v, user in pairs(sudo_users) do
    if user == user_id then
      var = true
    end
  end
  return var
end
-- Print message format. Use serpent for prettier result.
function vardump(value, depth, key)
  local linePrefix = ''
  local spaces = ''

  if key ~= nil then
    linePrefix = key .. ' = '
  end

  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do
      spaces = spaces .. '  '
    end
  end

  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces .. linePrefix .. '(table) ')
    else
      print(spaces .. '(metatable) ')
      value = mTable
    end
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)  == 'function' or
    type(value) == 'thread' or
    type(value) == 'userdata' or
    value == nil then --@AnOnySeCuRiTy
    print(spaces .. tostring(value))
  elseif type(value)  == 'string' then
    print(spaces .. linePrefix .. '"' .. tostring(value) .. '",')
  else
    print(spaces .. linePrefix .. tostring(value) .. ',')
  end
end

-- Print callback
function dl_cb(arg, data)
end


local function setowner_reply(extra, result, success)
  t = vardump(result)
  local msg_id = result.id_
  local user = result.sender_user_id_
  local ch = result.chat_id_
  redis:del('owners:'..ch)
  redis:set('owners:'..ch,user)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '`  کاربر  ` '..user..' `  اونرشد `', 1, 'md')
  print(user)
end

local function deowner_reply(extra, result, success)
  t = vardump(result)
  local msg_id = result.id_
  local user = result.sender_user_id_
  local ch = result.chat_id_
  redis:del('owners:'..ch)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '`  کاربر  ` '..user..'` از اونری حذف شد `', 1, 'md')
  print(user)
end

local database = 'http://vip.opload.ir/vipdl/94/11/amirhmz/'
local function setmod_reply(extra, result, success)
vardump(result)
local msg = result.id_
local user = result.sender_user_id_
local chat = result.chat_id_
redis:sadd('mods:'..chat,user)
tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '`  کاربر  `'..user..'` معاون شد  `', 1, 'md')
end

local function remmod_reply(extra, result, success)
vardump(result)
local msg = result.id_
local user = result.sender_user_id_
local chat = result.chat_id_
redis:srem('mods:'..chat,user)
tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '` کاربر `'..user..'` معاون حذف شد  `', 1, 'md')
end

function kick_reply(extra, result, success)
  b = vardump(result)
  tdcli.changeChatMemberStatus(result.chat_id_, result.sender_user_id_, 'Kicked')
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '` کاربر `'..result.sender_user_id_..' *kicked*', 1, 'md')
end

function ban_reply(extra, result, success)
  b = vardump(result)
  tdcli.changeChatMemberStatus(result.chat_id_, result.sender_user_id_, 'Banned')
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '` کاربر `'..result.sender_user_id_..' *banned*', 1, 'md')
end


local function setmute_reply(extra, result, success)
  vardump(result)
  redis:sadd('muteusers:'..result.chat_id_,result.sender_user_id_)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '` کاربر `'..result.sender_user_id_..' ` رفت تو سایلنت `', 1, 'md')
end

local function demute_reply(extra, result, success)
  vardump(result)
  redis:srem('muteusers:'..result.chat_id_,result.sender_user_id_)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '` کاربر `'..result.sender_user_id_..' ` حذف شد از سایلنت `', 1, 'md')
end



function tdcli_update_callback(data)
  vardump(data)

  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    local input = msg.content_.text_
    local chat_id = msg.chat_id_
    local user_id = msg.sender_user_id_
    local reply_id = msg.reply_to_message_id_
    vardump(msg)
    if msg.content_.ID == "MessageText" then
      if input == "on" then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '`on`', 1, 'md')

      end
      if input == "تست" then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>روشنم</b>', 1, 'html')
      end
      if input:match("^id$") then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<code>شناسه گروه: </code><code>'..string.sub(chat_id, 5,14)..'</code>\n<code>شناسه کابری: </code><code>'..user_id..'</code>\n<code>کانال: </code>@AnOnySeCuRiTy', 1, 'html')
      end

      if input:match("^pin$") and reply_id and is_owner(msg) then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>پیام پین شد</b>', 1, 'html')
        tdcli.pinChannelMessage(chat_id, reply_id, 1)
      end

      if input:match("^unpin$") and reply_id and is_owner(msg) then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>پیام از پین برداشته شد</b>', 1, 'html')
        tdcli.unpinChannelMessage(chat_id, reply_id, 1)
      end


      -----------------------------------------------------------------------------------------------------------------------------
      if input:match('^setowner$') and is_owner(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,setowner_reply,nil)
      end
      if input == "/delowner" and is_sudo(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,deowner_reply,nil)
      end

      if input:match('^owner$') then
        local hash = 'owners:'..chat_id
        local owner = redis:get(hash)
        if owner == nil then
          tdcli.sendText(chat_id, 0, 0, 1, nil, '`گروه اونر ندارد ` ', 1, 'md')
        end
        local owner_list = redis:get('owners:'..chat_id)
        text85 = '👤`اونرگروه :`\n\n '..owner_list
        tdcli.sendText(chat_id, 0, 0, 1, nil, text85, 1, 'md')
      end
      if input:match('^setowner (.*)') and not input:find('@') and is_sudo(msg) then
        redis:del('owners:'..chat_id)
        redis:set('owners:'..chat_id,input:match('^setowner (.*)'))
        tdcli.sendText(chat_id, 0, 0, 1, nil, '` کاربر `'..input:match('^setowner (.*)')..' ownered', 1, 'md')
      end

      if input:match('^setowner (.*)') and input:find('@') and is_owner(msg) then
        function Inline_Callback_(arg, data)
        redis:del('owners:'..chat_id)
        redis:set('owners:'..chat_id,input:match('^setowner (.*)'))
        tdcli.sendText(chat_id, 0, 0, 1, nil, '` کاربر `'..input:match('^setowner (.*)')..' ownered', 1, 'md')
        end
        tdcli_function ({ID = "SearchPublicChat",username_ =input:match('^setowner (.*)')}, Inline_Callback_, nil)
      end


      if input:match('^delowner (.*)') and is_sudo(msg) then
        redis:del('owners:'..chat_id)
        tdcli.sendText(chat_id, 0, 0, 1, nil, '` کاربر `'..input:match('^delowner (.*)')..' ` مدیر حذف شد `', 1, 'md')
      end
      -----------------------------------------------------------------------------------------------------------------------
      if input:match('^promote') and is_sudo(msg) and msg.reply_to_message_id_ then
tdcli.getMessage(chat_id,msg.reply_to_message_id_,setmod_reply,nil)
end
if input:match('^demote') and is_sudo(msg) and msg.reply_to_message_id_ then
tdcli.getMessage(chat_id,msg.reply_to_message_id_,remmod_reply,nil)
end
			
			sm = input:match('^promote (.*)')
if sm and is_sudo(msg) then
  redis:sadd('mods:'..chat_id,sm)
  tdcli.sendText(chat_id, 0, 0, 1, nil, '`کاربر \n`'..sm..'` معاون شد: `', 1, 'md')
end

dm = input:match('^demote (.*)')
if dm and is_sudo(msg) then
  redis:srem('mods:'..chat_id,dm)
  tdcli.sendText(chat_id, 0, 0, 1, nil, '`کاربر\n `'..dm..'` از معاونی برکنار شد: `', 1, 'md')
end

if input:match('^modlist') then
if redis:scard('mods:'..chat_id) == 0 then
tdcli.sendText(chat_id, 0, 0, 1, nil, '`مدیری نیست عخی`', 1, 'md')
end
local text = "`مدیران ربات درگروه:` \n"
for k,v in pairs(redis:smembers('mods:'..chat_id)) do
text = text.."_"..k.."_ - *"..v.."*\n"
end
tdcli.sendText(chat_id, 0, 0, 1, nil, text, 1, 'md')
end
						--------------------------------------------------------
			if input:match('^setlink (.*)') and is_owner(msg) then
redis:set('link'..chat_id,input:match('^setlink (.*)'))
tdcli.sendText(chat_id, 0, 0, 1, nil, '`لینک ذخیره شد`', 1, 'md')
end

if input:match('^[/!#]link') and is_owner(msg) then
link = redis:get('link'..chat_id)
tdcli.sendText(chat_id, 0, 0, 1, nil, '`لینک گروه:`\n'..link, 1, 'md')
end
		-------------------------------------------------------
		if input:match('^setrules (.*)') and is_owner(msg) then
redis:set('gprules'..chat_id,input:match('^setrules (.*)'))
tdcli.sendText(chat_id, 0, 0, 1, nil, '`قوانین ذخیره شد`', 1, 'md')
end

if input:match('^rules') then
rules = redis:get('gprules'..chat_id)
tdcli.sendText(chat_id, 0, 0, 1, nil, '`قوانین :`\n'..rules, 1, 'md')
end
--------------------------------------------------------------------------
local res = http.request(database.."joke.db")
	local joke = res:split(",")
 if input:match'[!/#](joke)' then
 local run = joke[math.random(#joke)]
 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, run..'\n\n*By* @Sc0rpion', 1, 'md')
 end
      ---------------------------------------------------------------------------------------------------------------------------------
      if input:match("^[#!/][Aa]dd$") and is_sudo(msg) then
        redis:sadd('groups',chat_id)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '` ربات اد شد توسط `'..msg.sender_user_id_..'', 1, 'md')
      end
      -------------------------------------------------------------------------------------------------------------------------------------------
      if input:match("^[#!/][Rr]em$") and is_sudo(msg) then
        redis:srem('groups',chat_id)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '` ربات غیر فعال شد توسط `'..msg.sender_user_id_..'', 1, 'md')
      end

      ----------------------------------------------------------
      if input:match('^muteuser') and is_mod(msg) and msg.reply_to_message_id_ then
        redis:set('tbt:'..chat_id,'yes')
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,setmute_reply,nil)
      end
      if input:match('^unmuteuser') and is_mod(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,demute_reply,nil)
      end
      mu = input:match('^muteuser (.*)')
      if mu and is_mod(msg) then
        redis:sadd('muteusers:'..chat_id,mu)
        redis:set('tbt:'..chat_id,'yes')
        tdcli.sendText(chat_id, 0, 0, 1, nil, '` کاربر `'..mu..' ` رفت تو سایلنت `', 1, 'md')
      end
      umu = input:match('^unmuteuser (.*)')
      if umu and is_mod(msg) then
        redis:srem('muteusers:'..chat_id,umu)
        tdcli.sendText(chat_id, 0, 0, 1, nil, '` کاربر `'..umu..' `حذف از سایلنت`', 1, 'md')
      end

      if input:match('^muteusers') then
        if redis:scard('muteusers:'..chat_id) == 0 then
          tdcli.sendText(chat_id, 0, 0, 1, nil, '`گروه سایلنت ندارد`', 1, 'md')
        end
        local text = "`سایلنت لیست:`\n"
        for k,v in pairs(redis:smembers('muteusers:'..chat_id)) do
          text = text.."<b>"..k.."</b> - <b>"..v.."</b>\n"
        end
        tdcli.sendText(chat_id, 0, 0, 1, nil, text, 1, 'html')
      end
      -------------------------------------------------------

      --lock links
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock links$") and is_mod(msg) and groups then
        if redis:get('lock_linkstg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `ضدلینک قفل بوده`', 1, 'md')
        else
          redis:set('lock_linkstg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `ضدلینک قفل`', 1, 'md')
        end
      end
      if input:match("^unlock links$")  and is_mod(msg) and groups then
        if not redis:get('lock_linkstg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `ضدلینک باز بوده`', 1, 'md')
        else
          redis:del('lock_linkstg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `ضدلینک باز`', 1, 'md')
        end
      end
      --lock username
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock username$") and is_mod(msg) and groups then
        if redis:get('usernametg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `یوزرنیم قفل بوده`', 1, 'md')
        else
          redis:set('usernametg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `یوزرنیم قفل`', 1, 'md')
        end
      end
      if input:match("^unlock username$") and is_mod(msg) and groups then
        if not redis:get('usernametg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `یوزرنیم باز بوده`', 1, 'md')
        else
          redis:del('usernametg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `یوزرنیم باز`', 1, 'md')
        end
      end
      --lock tag
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock tag$") and is_mod(msg) and groups then
        if redis:get('tagtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `تگ قفل بوده`', 1, 'md')
        else
          redis:set('tagtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `تگ قفل`', 1, 'md')
        end
      end
      if input:match("^unlock tag$") and is_mod(msg) and groups then
        if not redis:get('tagtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `تگ باز بوده`', 1, 'md')
        else
          redis:del('tagtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `تگ باز`', 1, 'md')
        end
      end
      --lock forward
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock fwd$") and is_mod(msg) and groups then
        if redis:get('forwardtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `فوروارد قفل بوده`', 1, 'md')
        else
          redis:set('forwardtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `فوروارد قفل`', 1, 'md')
        end
      end
      if input:match("^unlock fwd$") and is_mod(msg) and groups then
        if not redis:get('forwardtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `فوروارد باز بوده`', 1, 'md')
        else
          redis:del('forwardtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `فوروارد باز`', 1, 'md')
        end
      end
      --arabic/persian
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock abc$") and is_mod(msg) and groups then
        if redis:get('arabictg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `حروف فارسی قفل بوده`', 1, 'md')
        else
          redis:set('arabictg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `حروف فارسی قفل`', 1, 'md')
        end
      end
      if input:match("^unlock abc$") and is_mod(msg) and groups then
        if not redis:get('arabictg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `حروف فارسی باز بوده`', 1, 'md')
        else
          redis:del('arabictg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `حروف فارسی باز`', 1, 'md')
        end
      end
      ---english
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock eng$") and is_mod(msg) and groups then
        if redis:get('engtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `انگلیسی قفل بوده`', 1, 'md')
        else
          redis:set('engtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `انگلیسی قفل`', 1, 'md')
        end
      end
      if input:match("^unlock eng$") and is_mod(msg) and groups then
        if not redis:get('engtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `انگلیسی باز بوده`', 1, 'md')
        else
          redis:del('engtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `انگلیسی باز`', 1, 'md')
        end
      end
      --lock foshtg
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock fosh$") and is_mod(msg) and groups then
        if redis:get('badwordtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `فش قفل بوده`', 1, 'md')
        else
          redis:set('badwordtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `فش قفل`', 1, 'md')
        end
      end
      if input:match("^unlock fosh$") and is_mod(msg) and groups then
        if not redis:get('badwordtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `فش باز بوده`', 1, 'md')
        else
          redis:del('badwordtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `فش باز`', 1, 'md')
        end
      end
      --lock edit
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock edit$") and is_mod(msg) and groups then
        if redis:get('edittg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `ادیت قفل بوده`', 1, 'md')
        else
          redis:set('edittg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `ادیت قفل`', 1, 'md')
        end
      end
      if input:match("^unlock edit$") and is_mod(msg) and groups then
        if not redis:get('edittg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `ادیت باز بوده`', 1, 'md')
        else
          redis:del('edittg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `ادیت باز`', 1, 'md')
        end
      end
      --- lock Caption
      if input:match("^lock cap$") and is_mod(msg) and groups then
        if redis:get('captg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `کپشن قفل بوده`', 1, 'md')
        else
          redis:set('captg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `کپشن قفل`', 1, 'md')
        end
      end
      if input:match("^unlock cap$") and is_mod(msg) and groups then
        if not redis:get('captg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `کپشن بازبوده`', 1, 'md')
        else
          redis:del('captg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `کپشن باز`', 1, 'md')
        end
      end
      --lock emoji
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock emoji") and is_mod(msg) and groups then
        if redis:get('emojitg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `اموجی قفل بوده`', 1, 'md')
        else
          redis:set('emojitg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `اموجی قفل`', 1, 'md')
        end
      end
      if input:match("^unlock emoji$") and is_mod(msg) and groups then
        if not redis:get('emojitg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `اموجی باز بوده`', 1, 'md')
        else
          redis:del('emojitg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `اموجی باز`', 1, 'md')
        end
      end
      --- lock inline
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock inline") and is_mod(msg) and groups then
        if redis:get('inlinetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `اینلابن قفل بوده`', 1, 'md')
        else
          redis:set('inlinetg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `اینلاین قفل`', 1, 'md')
        end
      end
      if input:match("^unlock inline$") and is_mod(msg) and groups then
        if not redis:get('inlinetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `اینلابن باز بوده`', 1, 'md')
        else
          redis:del('inlinetg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `اینلاین باز`', 1, 'md')
        end
      end
      -- lock reply
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock reply") and is_mod(msg) and groups then
        if redis:get('replytg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `ریپلی قفل بوده`', 1, 'md')
        else
          redis:set('replytg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `ریپلی قفل`', 1, 'md')
        end
      end
      if input:match("^unlock reply$") and is_mod(msg) and groups then
        if not redis:get('replytg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `ریپلی باز بوده`', 1, 'md')
        else
          redis:del('replytg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `ریپلی باز`', 1, 'md')
        end
      end
      --lock tgservice
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock tgservice$") and is_mod(msg) and groups then
        if redis:get('tgservice:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `TGservice قفل بوده`', 1, 'md')
        else
          redis:set('tgservice:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `TGservice قفل`', 1, 'md')
        end
      end
      if input:match("^unlock tgservice$") and is_mod(msg) and groups then
        if not redis:get('tgservice:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `TGservice بازبوده`', 1, 'md')
        else
          redis:del('tgservice:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `TGservice بازشد`', 1, 'md')
        end
      end
      --lock flood (by @Flooding)
      groups = redis:sismember('groups',chat_id)
      if input:match("^lock flood") and is_mod(msg) and groups then
        if redis:get('floodtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `فلود قفل بوده`', 1, 'md')
        else
          redis:set('floodtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔐 `فلود قفل`', 1, 'md')
        end
      end
      if input:match("^unlock flood$") and is_mod(msg) and groups then
        if not redis:get('floodtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `فلود باز بوده`', 1, 'md')
        else
          redis:del('flood:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔓 `فلود بازشد`', 1, 'md')
        end
      end

      --------------------------------
      ---------------------------------------------------------------------------------
      local link = 'lock_linkstg:'..chat_id
      if redis:get(link) then
        link = "🔐"
      else
        link = "🔓"
      end

      local username = 'usernametg:'..chat_id
      if redis:get(username) then
        username = "🔐"
      else
        username = "🔓"
      end

      local tag = 'tagtg:'..chat_id
      if redis:get(tag) then
        tag = "🔐"
      else
        tag = "🔓"
      end

      local flood = 'floodtg:'..chat_id
      if redis:get(flood) then
        flood = "🔐"
      else
        flood = "🔓"
      end

      local forward = 'forwardtg:'..chat_id
      if redis:get(forward) then
        forward = "🔐"
      else
        forward = "🔓"
      end

      local arabic = 'arabictg:'..chat_id
      if redis:get(arabic) then
        arabic = "🔐"
      else
        arabic = "🔓"
      end

      local eng = 'engtg:'..chat_id
      if redis:get(eng) then
        eng = "🔐"
      else
        eng = "🔓"
      end

      local badword = 'badwordtg:'..chat_id
      if redis:get(badword) then
        badword = "🔐"
      else
        badword = "🔓"
      end

      local edit = 'edittg:'..chat_id
      if redis:get(edit) then
        edit = "🔐"
      else
        edit = "🔓"
      end

      local emoji = 'emojitg:'..chat_id
      if redis:get(emoji) then
        emoji = "🔐"
      else
        emoji = "🔓"
      end

      local caption = 'captg:'..chat_id
      if redis:get(caption) then
        caption = "🔐"
      else
        caption = "🔓"
      end

      local inline = 'inlinetg:'..chat_id
      if redis:get(inline) then
        inline = "🔐"
      else
        inline = "🔓"
      end

      local reply = 'replytg:'..chat_id
      if redis:get(reply) then
        reply = "🔐"
      else
        reply = "🔓"
      end
      ----------------------------
      --muteall
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute all$") and is_mod(msg) and groups then
        if redis:get('mute_alltg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`چت قفل بود`', 1, 'md')
        else
          redis:set('mute_alltg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`چت قفل شد`', 1, 'md')
        end
      end
      if input:match("^unmute all$") and is_mod(msg) and groups then
        if not redis:get('mute_alltg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`چت باز بود`', 1, 'md')
        else
          redis:del('mute_alltg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`چت باز شد`', 1, 'md')
        end
      end

      --mute sticker
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute sticker$") and is_mod(msg) and groups then
        if redis:get('mute_stickertg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`استیکر قفل بوده`', 1, 'md')
        else
          redis:set('mute_stickertg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`استیکرقفل`', 1, 'md')
        end
      end
      if input:match("^unmute sticker$") and is_mod(msg) and groups then
        if not redis:get('mute_stickertg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`استیکرباز بوده`', 1, 'md')
        else
          redis:del('mute_stickertg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`استیکر باز`', 1, 'md')
        end
      end
      --mute gift
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute gif$") and is_mod(msg) and groups then
        if redis:get('mute_gifttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`گیف قفل بوده`', 1, 'md')
        else
          redis:set('mute_gifttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`گیف قفل`', 1, 'md')
        end
      end
      if input:match("^unmute gif$") and is_mod(msg) and groups then
        if not redis:get('mute_gifttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`گیف باز بوده`', 1, 'md')
        else
          redis:del('mute_gifttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`گیف باز`', 1, 'md')
        end
      end
      --mute contact
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute contact$") and is_mod(msg) and groups then
        if redis:get('mute_contacttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`شماره قفل بوده`', 1, 'md')
        else
          redis:set('mute_contacttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`شماره قفل`', 1, 'md')
        end
      end
      if input:match("^unmute contact$") and is_mod(msg) and groups then
        if not redis:get('mute_contacttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`شماره باز بوده`', 1, 'md')
        else
          redis:del('mute_contacttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`شماره باز`', 1, 'md')
        end
      end
      --mute photo
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute photo$") and is_mod(msg) and groups then
        if redis:get('mute_phototg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`عکس قفل بوده`', 1, 'md')
        else
          redis:set('mute_phototg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`عکس قفل`', 1, 'md')
        end
      end
      if input:match("^unmute photo$") and is_mod(msg) and groups then
        if not redis:get('mute_phototg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`عکس باز بوده`', 1, 'md')
        else
          redis:del('mute_phototg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`عکس باز`', 1, 'md')
        end
      end
      --mute audio
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute audio$") and is_mod(msg) and groups then
        if redis:get('mute_audiotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`موزیک قفل بوده`', 1, 'md')
        else
          redis:set('mute_audiotg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`موزیک قفل`', 1, 'md')
        end
      end
      if input:match("^unmute audio$") and is_mod(msg) and groups then
        if not redis:get('mute_audiotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`موزیک باز بوده`', 1, 'md')
        else
          redis:del('mute_audiotg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`موزیک باز`', 1, 'md')
        end
      end
      --mute voice
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute voice$") and is_mod(msg) and groups then
        if redis:get('mute_voicetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`ویس قفل بوده`', 1, 'md')
        else
          redis:set('mute_voicetg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`ویس قفل`', 1, 'md')
        end
      end
      if input:match("^unmute voice$") and is_mod(msg) and groups then
        if not redis:get('mute_voicetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`ویس باز بوده`', 1, 'md')
        else
          redis:del('mute_voicetg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`ویس باز`', 1, 'md')
        end
      end
      --mute video
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute video$") and is_mod(msg) and groups then
        if redis:get('mute_videotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`فیلم قفل بوده`', 1, 'md')
        else
          redis:set('mute_videotg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`فیلم قفل`', 1, 'md')
        end
      end
      if input:match("^unmute video$") and is_mod(msg) and groups then
        if not redis:get('mute_videotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`فیلم باز بوده`', 1, 'md')
        else
          redis:del('mute_videotg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`فیلم باز`', 1, 'md')
        end
      end
      --mute document
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute document$") and is_mod(msg) and groups then
        if redis:get('mute_documenttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`داکیومنت قفل بوده`', 1, 'md')
        else
          redis:set('mute_documenttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`داکیومنت قفل`', 1, 'md')
        end
      end
      if input:match("^unmute document$") and is_mod(msg) and groups then
        if not redis:get('mute_documenttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`داکیومنت باز بوده`', 1, 'md')
        else
          redis:del('mute_documenttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`داکیومنت باز`', 1, 'md')
        end
      end
      --mute  text
      groups = redis:sismember('groups',chat_id)
      if input:match("^mute text$") and is_mod(msg) and groups then
        if redis:get('mute_texttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`تکست قفل بوده`', 1, 'md')
        else
          redis:set('mute_texttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔇`تکست قفل`', 1, 'md')
        end
      end
      if input:match("^unmute text$") and is_mod(msg) and groups then
        if not redis:get('mute_texttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`تکست باز بوده `', 1, 'md')
        else
          redis:del('mute_texttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🔊`تکست باز `', 1, 'md')
        end
      end
      --settings
      local all = 'mute_alltg:'..chat_id
      if redis:get(all) then
        All = "🔇"
      else
        All = "🔊"
      end

      local sticker = 'mute_stickertg:'..chat_id
      if redis:get(sticker) then
        sticker = "🔇"
      else
        sticker = "🔊"
      end

      local gift = 'mute_gifttg:'..chat_id
      if redis:get(gift) then
        gift = "🔇"
      else
        gift = "🔊"
      end

      local contact = 'mute_contacttg:'..chat_id
      if redis:get(contact) then
        contact = "🔇"
      else
        contact = "🔊"
      end

      local photo = 'mute_phototg:'..chat_id
      if redis:get(photo) then
        photo = "🔇"
      else
        photo = "🔊"
      end

      local audio = 'mute_audiotg:'..chat_id
      if redis:get(audio) then
        audio = "🔇"
      else
        audio = "🔊"
      end

      local voice = 'mute_voicetg:'..chat_id
      if redis:get(voice) then
        voice = "🔇"
      else
        voice = "🔊"
      end

      local video = 'mute_videotg:'..chat_id
      if redis:get(video) then
        video = "🔇"
      else
        video = "🔊"
      end

      local document = 'mute_documenttg:'..chat_id
      if redis:get(document) then
        document = "🔇"
      else
        document = "🔊"
      end

      local text1 = 'mute_texttg:'..chat_id
      if redis:get(text1) then
        text1 = "🔇"
      else
        text1 = "🔊"
      end
      if input:match("^settings$") and is_mod(msg) then
		local text = "⚙*Settings*⚙".."\n"
		.."\n".."🔰`Flood:    `".."*"..flood.."*".."\n"
		.."🔰`Link:     `".."*"..link.."*".."\n"
		.."🔰`Tag:      `".."*"..tag.."*".."\n"
		.."🔰`Username: `".."*"..username.."*".."\n"         	
		.."🔰`Forward:  `".."*"..forward.."*".."\n"
		.."🔰`Persian:  `".."*"..arabic..'*'..'\n'
		.."🔰`English:  `".."*"..eng..'*'..'\n'
		.."🔰`reply:    `".."*"..reply..'*'..'\n'
		.."🔰`Fosh:     `".."*"..badword..'*'..'\n'
		.."🔰`Edit:     `".."*"..edit..'*'..'\n'
		.."🔰`Caption:  `".."*"..caption..'*'..'\n'
		.."🔰`Inline:   `".."*"..inline..'*'..'\n'
		.."🔰`Emoji:    `".."*"..emoji..'*'..'\n'
		.."🔰`Chat:     `".."*"..All.."*".."\n"
		.."🔰`Sticker:  `".."*"..sticker.."*".."\n"
		.."🔰`Gif:      `".."*"..gift.."*".."\n"
		.."🔰`Contact:  `".."*"..contact.."*".."\n"
		.."🔰`Photo:    `".."*"..photo.."*".."\n"
		.."🔰`Audio:    `".."*"..audio.."*".."\n"
		.."🔰`Voice:    `".."*"..voice.."*".."\n"
		.."🔰`Video:    `".."*"..video.."*".."\n"
		.."🔰`Document: `".."*"..document.."*".."\n"
		.."🔰`Text:     `".."`"..text1.."`".."\n"
		     .."📞@AnOnySeCuRiTy"
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text, 1, 'md')
      end
      if input:match("^[#!/][Ff]wd$") then
        tdcli.forwardMessages(chat_id, chat_id,{[0] = reply_id}, 0)
      end

      if input:match("^[#!/][Uu]sername") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 11))
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Username Changed To </b>@'..string.sub(input, 11), 1, 'html')
      end

      if input:match("^[#!/][Ee]cho") then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, string.sub(input, 7), 1, 'html')
      end

      if input:match("^[#!/][Ss]etname") and is_owner(msg) then
        tdcli.changeChatTitle(chat_id, string.sub(input, 10), 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup Name Changed To </b><code>'..string.sub(input, 10)..'</code>', 1, 'html')
      end
	  
      if input:match("^[#!/][Cc]hangename") and is_sudo(msg) then
        tdcli.changeName(string.sub(input, 13), nil, 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Bot Name Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  
      if input:match("^[#!/][Cc]hangeuser") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 13), nil, 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Bot UserName Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  
      if input:match("^[#!/][Dd]eluser") and is_sudo(msg) then
        tdcli.changeUsername('')
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, 'Username Has Been Deleted', 1, 'html')
      end
	  
      if input:match("^[#!/][Ee]dit") and is_owner(msg) then
        tdcli.editMessageText(chat_id, reply_id, nil, string.sub(input, 7), 'html')
      end

      if input:match("^[#!/]delpro") and is_sudo(msg) then
        tdcli.DeleteProfilePhoto(chat_id, {[0] = msg.id_})
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b> profile has been deleted</b>', 1, 'html')
      end

      if input:match("^[#!/][Ii]nvite") and is_sudo(msg) then
        tdcli.addChatMember(chat_id, string.sub(input, 9), 20)
      end
	  
      if input:match("^[#!/][Cc]reatesuper") and is_sudo(msg) then
        tdcli.createNewChannelChat(string.sub(input, 14), 1, 'My Supergroup, my rules')
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup </b>'..string.sub(input, 14)..' <b>Created</b>', 1, 'html')
      end

      if input:match("^[#!/]del") and is_mod(msg) and msg.reply_to_message_id_ ~= 0 then
        tdcli.deleteMessages(msg.chat_id_, {[0] = msg.reply_to_message_id_})
      end

      if input:match('^[#!/]tosuper') then
        local gpid = msg.chat_id_
        tdcli.migrateGroupChatToChannelChat(gpid)
      end

      if input:match("^[#!/]view") then
        tdcli.viewMessages(chat_id, {[0] = msg.id_})
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Messages Viewed</b>', 1, 'html')
      end
    end

    local input = msg.content_.text_
    if redis:get('mute_alltg:'..chat_id) and msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_stickertg:'..chat_id) and msg.content_.sticker_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_gifttg:'..chat_id) and msg.content_.animation_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_contacttg:'..chat_id) and msg.content_.contact_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_phototg:'..chat_id) and msg.content_.photo_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_audiotg:'..chat_id) and msg.content_.audio_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_voicetg:'..chat_id) and msg.content_.voice_  and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_videotg:'..chat_id) and msg.content_.video_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_documenttg:'..chat_id) and msg.content_.document_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_texttg:'..chat_id) and msg.content_.text_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    if redis:get('forwardtg:'..chat_id) and msg.forward_info_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    local is_link_msg = input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or input:match("[Tt].[Mm][Ee]/") or input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Dd][Oo][Gg]/")
    if redis:get('lock_linkstg:'..chat_id) and is_link_msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('tagtg:'..chat_id) and input:match("#") and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('usernametg:'..chat_id) and input:match("@") and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('arabictg:'..chat_id) and input:match("[\216-\219][\128-\191]") and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_english_msg = input:match("[a-z]") or input:match("[A-Z]")
    if redis:get('engtg:'..chat_id) and is_english_msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_fosh_msg = input:match("کیر") or input:match("کس") or input:match("کون") or input:match("85") or input:match("جنده") or input:match("ننه") or input:match("ننت") or input:match("مادر") or input:match("قهبه") or input:match("گایی") or input:match("سکس") or input:match("kir") or input:match("kos") or input:match("kon") or input:match("nne") or input:match("nnt")
    if redis:get('badwordtg:'..chat_id) and is_fosh_msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_emoji_msg = input:match("😀") or input:match("😬") or input:match("😁") or input:match("😂") or  input:match("😃") or input:match("😄") or input:match("😅") or input:match("☺️") or input:match("🙃") or input:match("🙂") or input:match("😊") or input:match("😉") or input:match("😇") or input:match("😆") or input:match("😋") or input:match("😌") or input:match("😍") or input:match("😘") or input:match("😗") or input:match("😙") or input:match("😚") or input:match("🤗") or input:match("😎") or input:match("🤓") or input:match("🤑") or input:match("😛") or input:match("😏") or input:match("😶") or input:match("😐") or input:match("😑") or input:match("😒") or input:match("🙄") or input:match("🤔") or input:match("😕") or input:match("😔") or input:match("😡") or input:match("😠") or input:match("😟") or input:match("😞") or input:match("😳") or input:match("🙁") or input:match("☹️") or input:match("😣") or input:match("😖") or input:match("😫") or input:match("😩") or input:match("😤") or input:match("😲") or input:match("😵") or input:match("😭") or input:match("😓") or input:match("😪") or input:match("😥") or input:match("😢") or input:match("🤐") or input:match("😷") or input:match("🤒") or input:match("🤕") or input:match("😴") or input:match("💋") or input:match("❤️")
    if redis:get('emojitg:'..chat_id) and is_emoji_msg and not is_mod(msg)  then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('captg:'..chat_id) and  msg.content_.caption_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('locatg:'..chat_id) and  msg.content_.location_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('inlinetg:'..chat_id) and  msg.via_bot_user_id_ ~= 0 and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('replytg:'..chat_id) and  msg.reply_to_message_id_ and not is_mod(msg) ~= 0 then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('tbt:'..chat_id) and is_normal(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    -- AntiFlood --
    local floodMax = 8
    local floodTime = 2
    local hashflood = 'floodtg:'..msg.chat_id_
    if redis:get(hashflood) and not is_mod(msg) then
      local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
      local msgs = tonumber(redis:get(hash) or 0)
      if msgs > (floodMax - 1) then
        tdcli.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
        tdcli.sendText(msg.chat_id_, msg.id_, 1, 'User _'..msg.sender_user_id_..' ` kicked for Spam` !', 1, 'md')
        redis:setex(hash, floodTime, msgs+1)
      end
    end
    -- AntiFlood --
		elseif data.ID == "UpdateMessageEdited" then
if redis:get('edittg:'..data.chat_id_) then
  tdcli.deleteMessages(data.chat_id_, {[0] = tonumber(data.message_id_)})
end 
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
	
    -- @AnOnySeCuRiTy
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
