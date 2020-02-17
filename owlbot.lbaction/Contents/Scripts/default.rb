require 'uri'
require "base64"
require 'json'
require 'time'
require './owlbot.rb'

def actionItems()
  return []
end

def handleLaunch()
  return actionItems()
end

def translate(word)
  command = OwlBotCommand.new(word)
  if (command.run && command.definitions.count > 0)
    return definitionsToItems(command.definitions)
  else
    return [emptyResultItem]
  end
end

def definitionsToItems(definitions)
  resultItems = []
  definitions.each do |v|
    resultItems += [phraseItem(v)]

    v.examples.each { |m|
      resultItems += [exampleItem(m)]
    }
  end

  return resultItems
end

# ==== getting items

def emptyResultItem
  item = {}
  item['title'] = 'Result is empty'
  return item
end

def phraseItem(translate)
  item = {}
  item['title'] = translate.definition
  return item
end

def exampleItem(example)
  item = {}
  item['title'] = "* " + example
  return item
end


# ====

def handleArgs(arg)
  act = arg['_act']
  items = []
  
  if act == 'launch' 
    items = handleLaunch()
  
  elsif act == "translate"
    word = arg['_word']
    items = translate(word)
    
  else 
    item = {}
    item['title'] = "Unknown Command: " + act
    item['action'] = "default.rb"
    item['actionReturnsItems'] = true
    
    items.push(item)
  end
  
  return items
end

def detectLang(word)
  lang = "eng"
  if word =~ /[абвгдеёжзийклмнопрстуфхцчшщъыьэюя]/
    lang = "ru"
  end

  return lang
end

items = []
if ARGV.length > 0
  items = handleArgs({'_act'=>'translate', '_word'=>ARGV[0].downcase})
else 
  items = handleArgs({'_act'=>'launch'})
end

# puts handleArgs({'_act'=>'translate', '_word'=>"cat"})
puts items.to_json
