-- License notice: AGPL-3.0-only
   --[[
Bible bot is free software: you can redistribute it and/or modify
   it under the terms of the GNU AFFERO General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   Bible bot is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU AFFERO General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with Bible bot.  If not, see <https://www.gnu.org/licenses/>.
--]]
-- it allow me to generatom infinite window 0that have the "same" name
-- it's for testing purpose, do not touch if you arent developping the scrip
-- it's meant for protosmasher widnow lib that authorize you to only have 1 window
-- that have the same name
-- math.randomseed is used to get a true random for the answers so the answer wont be always be the same

-- Original script by vinidalvino on v3rm
-- Adapted by Skribb11es#0001 for use in Phantom Forces, as per the request of ࿊ּ#0206

math.randomseed(tick())
local __IS_TESTING = false
local HttpService = game:GetService "HttpService"
local Players = game:GetService("Players")
local sendBotMessage = false
-- config
__DEFAULT_SETTING_CONFIG = {
   adDelay = 30;
   delayPreset = 1;
   doNotWelcome = false;
   isNotDoingAd = false;
   isBibleBotDisabled = false;
   isHidingCustomMessageDesc = false;
   blacklisted = {};
}

__DEFAULT_CUSTOM_MESSAGE = {
   WelcomeMessage = {};
   PrayAnswer = {};
   ConffesionAnswer = {};
   BotAdvertisment = {};
   AskGodAnswer = {};
   AntiShutUpMessage = {}
}

if not pcall(readfile,"bible_bot_config.json") then
   writefile("bible_bot_config.json",HttpService:JSONEncode(__DEFAULT_SETTING_CONFIG))
end

if not pcall(readfile,"bible_bot_custom_message.json") then
   writefile("bible_bot_custom_message.json",HttpService:JSONEncode(__DEFAULT_CUSTOM_MESSAGE))
end
-- setting
settingConfig = HttpService:JSONDecode(readfile("bible_bot_config.json"))
updateSettingConfig = function() writefile("bible_bot_config.json",HttpService:JSONEncode(settingConfig)) end
-- custom message
customMessageConfig = HttpService:JSONDecode(readfile("bible_bot_custom_message.json"))
updateMessageConfig = function() writefile("bible_bot_custom_message.json",HttpService:JSONEncode(customMessageConfig)) end

-- settings

adDelay = settingConfig.adDelay
isNotDoingAd = true
isBibleBotDisabled = false
isGreeter = false

getVerse = function()
   local response = HttpService:JSONDecode(game:HttpGet("http://labs.bible.org/api/?passage=random&type=json"))
   return response[1].bookname .. " " .. response[1].chapter .. ":" .. response[1].verse .. " " .. response[1].text
end

local t = tick()
local nbOfChat = 0
local timeToWait = 0
chat = function(content)
   if settingConfig.isBibleBotDisabled then return end
   if tick() - t <= 0.60 and nbOfChat < 5 and nbOfChat > 2 then
       timeToWait = 10
   end
   wait(timeToWait)
   game:GetService("ControllerService").RemoteEvent:FireServer("chatted", content)
   t = tick()
   if nbOfChat >= 5 then nbOfChat = 0 timeToWait = 0 end
end


commands = {};

commands.verse = function()
   local bible = getVerse()
   if string.len(bible) > 200 then
       repeat
           game:GetService("RunService").Heartbeat:Wait()
           bible = getVerse()
       until string.len(bible) < 200
   end
   chat(bible)
end

commands.askgod = function(Player)
   local ans = {
       "Yes"; "No"; "It may be best for you not to know"; "Your question is beyond your mortal comprehension."; "Blasphemy! Ask no more."; "I do not care to entertain your trivial question.";
       "You should be ashamed of what you are asking."; "Perhaps."; "I have nothing to say about it"; "I refuse to answer that"; "This is not a question befit for me, ask another."; "Try re-asking that question, I can't purely understand a thing you're saying.";
       "A pity, made in my image yet couldn't ask a more reasonable question for me...";"Such foul words, I am ashamed of you";"Think twice of what you ask of me.";
       "What you are asking me is blasphemy! Confess your sin to me or face your consequences";"You exist to suffer, no further comment.";"I didn't set fire to Gommorah for you to ask such a foolish question!";"Your question is why Judgement Day will come for us sooner than before.";"This question is beneath me, ask another!";
   }
   if #customMessageConfig.AskGodAnswer ~= 0 then
       for _,m in next, customMessageConfig.AskGodAnswer do
           if string.find(m,"HUMAN") then
               local stringRepl = string.gsub(m,"HUMAN",Player.Name)
               table.insert(ans,stringRepl)
           else
               table.insert(ans,m)
           end
       end
   end
   chat(ans[math.random(#ans)])
end

commands.help = function()
   chat("!ask god [question] - Ask God a question | !verse - Study the holy bible | !help - Show this help menu | !confess [sin], confess your actions to God | !pray [prayer] pray for something")
   wait(0.5)
end

commands.confesion = function(Player,message)
   local ans = {"Your sin has been forgiven, rejoice!";"I am overjoyed you have acknowledged your sin, God shall forgive you.";"You are forgiven, be glad Jesus died for your sake.";"I can see your sin weighs heavily on you, God has forgiven you!";"This is a sin that can not be easily forgiven, I demand you say Glory To God 20 times!";"Your sin mocks the commandments put forth by Our Almighty God, 20 Holy Mary's!";"Your blasphemy ends here, pray Our Father and Holy Mary 30 times each right now!";"Your actions disgust our Lord";"Satan, smite " .. Player.Name .. " down for " .. Player.Name .. " has dared to defy God himself."};
   if #customMessageConfig.ConffesionAnswer ~= 0 then
       for _,customAns in next,customMessageConfig.ConffesionAnswer do
           if string.find(customAns,"HUMAN") then
               local stringRepl = string.gsub(customAns,"HUMAN",Player.Name)
               table.insert(ans,stringRepl)
           else
               table.insert(ans,customAns)
           end
       end
   end
   chat(ans[math.random(#ans)])
end

commands.pray = function(Player,message)
  local possibleAns = {"Amen";"Your greed terrifies me, confess your sin so that I may judge you by typing !confess [describe your foul actions here]";"Your prayer will be answered, Hallelujah!";"Your prayer has been rejected for blasphemy! type !confess [your sin here] for judgement.";"I understand your feelings, it shall be done soon";"What you ask will be done, be patient my son";"Your prayer will be granted, when the time comes."}
   if #customMessageConfig.PrayAnswer ~= 0 then
       game:GetService("RunService").Heartbeat:Wait()
       for _,msg in next,possibleAns do
           if string.find(msg,"HUMAN") then
               local messageRepl = string.gsub(msg,"HUMAN",Player.Name)
               table.insert(possibleAns,messageRepl)
           else
               table.insert(possibleAns,msg)
           end
       end
   end
   chat(possibleAns[math.random(#possibleAns)])
end

-- i seriously do not know what im doing so im taking a leap of faith so wish me luck boyos - Gaijin
-- i just copied everything from the confession function rofl - also Gaijin
commands.shut_up = function(Player,message)
   local possibleAns = {"Do not say that out loud, ";"Do you really want me to cleanse your mouth with holy water?";"I will not tolerate you saying the words that consist of the letters 's h u t  u p' being said in this server, so take your own advice and close thine mouth in the name of the Christian Roblox place owner.";"That is not how you treat the members of the Church,"}
   if #customMessageConfig.AntiShutUpMessage ~= 0 then
       game:GetService("RunService").Heartbeat:Wait()
       for _,msg in next,possibleAns do
           if string.find(msg,"HUMAN") then
               local messageRepl = string.gsub(msg,"HUMAN",Player.Name)
               table.insert(possibleAns,messageRepl)
           else
               table.insert(possibleAns,msg)
           end
       end
   end
   chat(possibleAns[math.random(#possibleAns)])
end


onPlayerChat = function(recipient,message)
   for i,v in next,settingConfig.blacklisted do if v == recipient.Name then return  end end
   message = string.lower(message)
   if message:match(".*!ask.-god.*") then
       commands.askgod(recipient)
   elseif message:match(".*!verse.*") or message:match(".!bible.*") then
       commands:verse()
   elseif message:match(".*!help.*") then
       commands:help()
   elseif message:match(".*!pray.*") then
       commands.pray(recipient,message)
   elseif message:match(".*!confess.*") then
       commands.confesion(recipient,message)
   elseif string.find(message,"shut up") then
       commands.shut_up(recipient,message)
   end
end

game.Players.LocalPlayer.PlayerGui.ChatGame.GlobalChat.ChildAdded:Connect(function(message)
   wait()
   if string.gsub(message.Text," : ", "") ~= "[Console]:" or string.gsub(message.Text," : ", "") ~= "System:" then
       sendBotMessage = not sendBotMessage
       if sendBotMessage == true then
           onPlayerChat(game.Players[string.gsub(message.Text," : ", "")], message.Msg.Text)
       end
   end
end)

Players.PlayerAdded:Connect(function(NewPlayer)
   local welcomeSentence = {
       "Greetings " .. NewPlayer.Name .. ", study the bible to further your blossoming faith by chatting !verse";
       "Welcome " .. NewPlayer.Name .. "! to Bibleblox! Study the bible with upmost vigor by chatting !verse";
       "Welcome to the holiest place in Roblox " .. NewPlayer.Name .. ". Study the bible as soon as possible by chatting !verse";
       "Feel free to ask any question to Our Almighty God by chatting !ask god [question]";
       "Welcome to the most Christian place in Roblox " .. NewPlayer.Name .. ".";
       function()
           if os.date("*t").hour > 12 and os.date("*t").hour < 18 then
               return "Welcome " .. NewPlayer.Name .. " to the afternoon bible study session. Open your bible by chatting !verse."
           elseif os.date("*t").hour > 18  or os.date("*t").hour < 5 then
               return "Welcome " .. NewPlayer.Name .. " to the night bible study session. Open your bible by chatting !verse."
           elseif os.date("*t").hour > 5  and os.date("*t").hour < 12 then
               return "Welcome " .. NewPlayer.Name .. " to the morning bible study session. Open your bible by chatting !verse."
           end
       end;
       function()
           if os.date("*t").hour > 12 and os.date("*t").hour < 18 then
               return "Gosh! you're late to the afternoon bible study session! Open your bible by chatting !verse quickly!!"
           elseif os.date("*t").hour > 18  or os.date("*t").hour < 5 then
               return "I can't believe you are, ahem, THIS late to the night bible study! Open the bible ASAP(chat !verse)"
           elseif os.date("*t").hour > 5  and os.date("*t").hour < 12 then
               return "Oh my! You are late to the morning bible study session! Chat !verse to open the bible"
           end
       end;
       function()
           if os.date("*t").hour > 12 and os.date("*t").hour < 18 then
               return "God will give you a second chance for making him wait " .. 18 - os.date("*t").hour .. " to listen your question(Chat !ask god to ask question) JUST DONT MAKE GOD WASTE HIS TIME"
           elseif os.date("*t").hour > 18  or os.date("*t").hour < 5 then
               return "God will give you a second chance for making him wait " .. os.date("*t").hour - 5 .. " to listen your question(Chat !ask god to ask question) JUST DONT MAKE GOD WASTE HIS TIME"
           elseif os.date("*t").hour > 5  and os.date("*t").hour < 12 then
               return "God will give you a second for making him wait " .. os.date("*t").hour - 5 .. " to listen your question(Chat !ask god to ask question) JUST DONT MAKE GOD WASTE HIS TIME"
           end
       end;
   }
   if #customMessageConfig.WelcomeMessage ~= 0 then
       for i,message in pairs(customMessageConfig.WelcomeMessage) do
           if string.find(message,"HUMAN") then
               local messageRepl = string.gsub(message,"HUMAN",NewPlayer.Name)
               table.insert(welcomeSentence,messageRepl)
           else
               table.insert(welcomeSentence,message)
           end
       end
   end
   for cycle,sentence in next,welcomeSentence do
       if isGreeter == false then
           if cycle == math.random(#welcomeSentence) then
               if type(sentence) == "function" then
                   chat(sentence())
               else
                   chat(sentence)
               end
               break
           end
       end
   end
end)

ad = {
   "Greetings all, I am Bible bot! And I guide the masses towards realizing the true faith. Chat !help to know all the available commands for me";
   "I have come forth to bring the good news to all! Chat !verse to hear of it";
   "Do not live in sin or suffer for eternity in hell! Chat !help to know the availaible commands for bible bot";
   "Always remember to pray to God. Chat !pray [someone or something you want] to learn what He has in store for your prayer";
   "Remember to study the bible and praise Our Lord God to further your love for Him. type !verse to study a verse of the bible, Chat !help to know other commands";
   "Submit to the divine authority of God and learn more of the one true faith by typing !help to know all the availaible commands of bible bot"
}
oldAdTimerValue = adDelay
oldState = isNotDoingAd
--[[ game:GetService("RunService").Heartbeat:Connect(function()

end)
]]
__TIME_WITHIN_EACH__CONFIG_SAVE = 0.1
-- advertisement corutine
coroutine.resume(coroutine.create(function()
   while game:GetService("RunService").Heartbeat:Wait() do
      ad = {
          "Greetings all, I am Bible bot. I guide the masses towards realizing the true faith. Chat !help to know all the available commands for me";
          "I have come forth to bring the good news to all! Chat !verse to hear of it";
          "Do not commit sin or suffer for eternity in hell! Chat !help to know the availaible commands for bible bot";
          "Always remember to pray to God. Chat !pray [someone or something you want] to learn what He has in store for your prayer";
          "Remember to study the bible to further your love for God. type !verse to study a verse of the bible, Chat !help to know other commands";
          "Submit to the divine authority of God and learn more of the one true faith by typing !help to know all the availaible commands of bible bot"
      }
       if #customMessageConfig.BotAdvertisment ~= 0 then
           local Player = game:GetService("Players"):GetPlayers()
           for _,customMsg in next,customMessageConfig.BotAdvertisment do
               if string.find(customMsg,"HUMAN") then
                   local stringRepl = string.gsub(customMsg,"HUMAN",
                   Player[math.random(#Player)].Name)
                   table.insert(ad,stringRepl)
               else
                   table.insert(ad,customMsg)
               end
           end
       end
       if not isNotDoingAd then
           chat(ad[math.random(#ad)])
       end
       wait(adDelay)
   end
end))

-- update config coroutine
coroutine.resume(coroutine.create(function()
   while wait(5) do
       settingConfig.isNotDoingAd = isNotDoingAd
       settingConfig.doNotWelcome = isGreeter
       settingConfig.adDelay = adDelay
       settingConfig.isBibleBotDisabled = isBibleBotDisabled
       updateSettingConfig()
   end
end))
