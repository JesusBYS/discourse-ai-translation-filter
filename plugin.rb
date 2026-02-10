# name: discourse-ai-translation-filter
# about: Correction du double échappement (\n et \u003e) dans les traductions
# version: 0.3

after_initialize do
  module ::AiTranslationFilter
    def self.clean_translation(text)
      return text if text.blank?

      # On utilise une astuce Ruby pour interpréter les séquences d'échappement 
      # comme le ferait un parseur JSON (gère \n, \u003e, \", etc.)
      begin
        # On entoure de guillemets pour simuler une string JSON valide
        cleaned = JSON.parse("\"#{text}\"")
        
        # Si après passage JSON il reste des \u003e textuels (cas rares)
        cleaned = cleaned.gsub('\u003e', '>') if cleaned.include?('\u003e')
        
        cleaned
      rescue JSON::ParserError
        # Si le parsing échoue, on se rabat sur un gsub manuel robuste
        text.gsub('\\n', "\n")
            .gsub('\n', "\n")
            .gsub('\u003e', '>')
            .gsub('\\u003e', '>')
      end
    end
  end

  reloadable_patch do
    if defined?(DiscourseAi::Translator::LlmTranslator)
      DiscourseAi::Translator::LlmTranslator.class_eval do
        alias_method :old_translate, :translate

        def translate(post, target_lang)
          result = old_translate(post, target_lang)
          
          if result && result[:translation]
            # On nettoie la chaîne avant qu'elle ne soit renvoyée à Discourse
            result[:translation] = ::AiTranslationFilter.clean_translation(result[:translation])
          end
          
          result
        end
      end
    end
  end
end
