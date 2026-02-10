# name: discourse-ai-translation-filter
# about: Intercepte l'écriture en BDD pour nettoyer les strings de traduction
# version: 1.0
# authors: JesusBYS

after_initialize do
  # Discourse AI stocke les traductions dans PostCustomField avec une clé spécifique
  # La clé ressemble généralement à "translated_text_#{lang}"
  
  on(:post_custom_field_changed) do |name, value, post|
    if name.start_with?("translated_text_") && value.is_a?(String)
      
      # Nettoyage profond
      cleaned_value = value.gsub('\\n', "\n")
                           .gsub('\n', "\n")
                           .gsub('\\u003e', '>')
                           .gsub('\u003e', '>')

      # Si la valeur a été modifiée, on la met à jour en BDD sans déclencher de nouveaux hooks
      if cleaned_value != value
        post.custom_fields[name] = cleaned_value
        post.save_custom_fields(true)
      end
    end
  end
end
