class DocumentGenerator
  attr_reader :template, :mapping, :xlsx

  def initialize(docs, excel_file)
    @template = docs.file
    @mapping = docs.metadata
    @excel_file = excel_file

    #template_config = load_template_config(@template)
  end

  def generate
    xlsx = Roo::Excelx.new(StringIO.new(@excel_file.blob.download))

    xlsx.each_row_streaming(offset: 1) do |row|
      row.map(&:value)
    end

    raise "Шаблон не найден" unless @template.file.attached?

    @replacements.count.times do |i|
      begin
        doc = Docx::Document.open(download_template_file)
      rescue => e
        raise "Ошибка при открытии документа: #{e.message}"
      end

      replace_text_in_paragraphs(doc, @replacements[i])
      replace_text_in_tables(doc, @replacements[i])

      file_name = Time.now.strftime("%Y-%m-%d_%H-%M-%S") + "_#{Time.now.usec / 1000}"
      output_path = Rails.root.join('tmp', "#{file_name}.docx")
      doc.save(output_path)
    end
  end

  private

  def download_template_file
    @template.file.download
  end

  def replace_text_in_paragraphs(doc, replacement)
    replacement.each do |key, value|
      doc.paragraphs.each do |p|
        p.text = p.text.gsub(placeholders[key], value)
      end
    end
  end

  def replace_text_in_tables(doc, replacement)
    doc.tables.each do |table|
      table.rows.each do |row|
        row.cells.each do |cell|
          replacement.each do |key, value|
            cell.paragraphs.each do |p|
              p.text = p.text.gsub("{#{key}}", value)
            end
          end
        end
      end
    end
  end

  def load_template_config(template)
    base_name = template.title.gsub(' ', '_').downcase
    yaml_path = Rails.root.join('app', 'mapping', "#{base_name}.yml")

    # Добавим вывод для проверки пути
    puts "Загружаем файл маппинга: #{yaml_path}"

    unless File.exist?(yaml_path)
      raise "Маппинг #{base_name}.yml не найден по пути #{yaml_path}"
    end

    begin
      config = YAML.load_file(yaml_path)
    rescue StandardError => e
      raise "Ошибка при загрузке YAML файла: #{e.message}"
    end

    raise "Маппинг для шаблона #{template.title} не найден в файле #{yaml_path}" unless config

    {
      path: Rails.root.join('app', 'templates', config['path']).to_s,
      placeholders: config['placeholders']
    }
  end
end
