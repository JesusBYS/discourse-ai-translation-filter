# name: discourse-ai-translation-filter
# about: Nettoie les caractères d'échappement (\u003e et \n) dans les traductions IA
# version: 0.2
# authors: JesusBYS

after_initialize do
  module ::AiTranslationFilter
    def self.clean_translation(text)
      return text if text.blank?

      # 1. Remplace l'entité Unicode du chevron par le caractère >
      # 2. Remplace la chaîne de caractères "\n" par un vrai retour à la ligne
      text.gsub('\u003e', '>')
          .gsub('\n', "\n")
    end
  end

  reloadable_patch do
    if defined?(DiscourseAi::Translator::LlmTranslator)
      DiscourseAi::Translator::LlmTranslator.class_eval do
        alias_method :old_translate, :translate

        def translate(post, target_lang)
          result = old_translate(post, target_lang)
          
          if result && result[:translation]
            result[:translation] = ::AiTranslationFilter.clean_translation(result[:translation])
          end
          
          result
        end
      end
    end
  end
end
