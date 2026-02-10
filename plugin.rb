# name: discourse-ai-translation-filter
# about: Corrige l'affichage des \n et \u003e dans les traductions IA
# version: 0.1
# authors: JesusBYS
# url: https://github.com/JesusBYS/discourse-ai-translation-filter

after_initialize do
  module ::DiscourseAiCleaner
    def self.clean(text)
      return text if text.blank?

      # Correction des doubles échappements (ex: \\n devient un vrai saut de ligne)
      # Et remplacement de l'entité unicode \u003e par le chevron >
      text.gsub('\\n', "\n")
          .gsub('\n', "\n")
          .gsub('\\u003e', '>')
          .gsub('\u003e', '>')
    end
  end

  # On "patch" le traducteur LLM de Discourse AI
  if defined?(DiscourseAi::Translator::LlmTranslator)
    reloadable_patch do
      DiscourseAi::Translator::LlmTranslator.class_eval do
        alias_method :old_translate, :translate

        def translate(post, target_lang)
          result = old_translate(post, target_lang)
          
          if result && result[:translation]
            result[:translation] = ::DiscourseAiCleaner.clean(result[:translation])
          end
          
          result
        end
      end
    end
  end
end
