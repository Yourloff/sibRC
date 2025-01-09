class DocumentGenerator

  attr_reader :template_path, :placeholders, :replacements
  def initialize(document_name, replacements)
    template_config = load_template_config(document_name)
    @template_path = template_config[:path]
    @placeholders = template_config[:placeholders]
    @replacements = replacements
  end

  def generate
    raise "Шаблон не найден по пути: #{@template_path}" unless File.exist?(@template_path)

    begin
      doc = Docx::Document.open(@template_path)
    rescue => e
      raise "Ошибка при открытии документа: #{e.message}"
    end

    replace_text_in_paragraphs(doc)

    replace_text_in_tables(doc)

    output_path = Rails.root.join('tmp', 'generated_document.docx')
    doc.save(output_path)
    output_path
  end

  private

  def replace_text_in_paragraphs(doc)
    @replacements.each do |replacement|
      replacement.each do |key, value|
        doc.paragraphs.each do |p|
          p.text = p.text.gsub(placeholders[key], value)
        end
      end
    end
  end

  def replace_text_in_tables(doc)
    doc.tables.each do |table|
      table.rows.each do |row|
        row.cells.each do |cell|
          # Перебираем каждый хэш замен
          @replacements.each do |replacement|
            # Перебираем все плейсхолдеры и их значения
            replacement.each do |key, value|
              # Для каждой ячейки, перебираем ее параграфы и заменяем текст в них
              cell.paragraphs.each do |p|
                p.text = p.text.gsub("{#{key}}", value)
              end
            end
          end
        end
      end
    end
  end

  def load_template_config(document_name)
    base_name = File.basename(document_name, File.extname(document_name))
    yaml_path = Rails.root.join('app', 'mapping', "#{base_name}.yml")

    unless File.exist?(yaml_path)
      raise "Маппинг #{base_name}.yml не найден по пути #{yaml_path}"
    end

    begin
      config = YAML.load_file(yaml_path)
    rescue StandardError => e
      raise "Ошибка при загрузке YAML файла: #{e.message}"
    end

    raise "Маппинг #{base_name} не найден в файле #{yaml_path}" unless config

    {
      path: Rails.root.join('app', 'templates', config['path']).to_s,
      placeholders: config['placeholders']
    }
  end
end
