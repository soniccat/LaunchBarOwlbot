require 'net/http'
require 'net/https'
require 'json'

class OwlBotCommand

  attr_accessor :phrase, :definitions
  def initialize(phrase)
    @phrase = phrase
  end

  def run
    command = "https://owlbot.info/api/v4/dictionary/" + @phrase
    uri = URI(URI::encode(command))

    res = nil
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      request = Net::HTTP::Get.new(uri)
      request["Authorization"] = "Token 0ca7d10d16988f232cf6821d79c4191a3b82f7d6"
      res = http.request request

      if res.code.to_i.between?(200,299)
        res = res.body
        @definitions = handleBody(res)
      end
    end

    return definitions != nil
  end

  def handleBody(body)
    data = JSON.load body
    return handleDefinitions(data['definitions'])
  end

  def handleDefinitions(definitions)
    phrases = []
    definitions.each { |v|
      phrase = parsePhrase(v)
      if (phrase)
        phrases += [phrase]
      end
    }

    return phrases
  end

  def parsePhrase(v)
    phrase = OwlBotDefinition.new()
    phrase.definition = v['definition']
    phrase.examples = []

    example = v['example']
    if (example != nil)
      phrase.examples = [example]
    end

    if (!phrase.isValid)
      phrase = nil
    end

    return phrase
  end
end

class OwlBotDefinition
  attr_accessor :definition, :examples

  def isValid()
    return definition != nil && examples != nil
  end
end

# command = OwlBotCommand.new("glee")
# p command.run
# p command.definitions
