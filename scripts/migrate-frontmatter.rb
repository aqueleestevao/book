#!/usr/bin/env ruby
# Migra front matter das páginas em 100/ para o novo schema:
#   layout: chapter
#   number: "x.y.z"
#   order: <inteiro computado do number>
#   title: "título sem prefixo numérico"
#
# Uso: ruby scripts/migrate-frontmatter.rb

require "yaml"

PAGES_DIR = "100"
RENUMBER_FILE = "scripts/renumber.txt"

# Carrega o mapeamento filename → número (para arquivos ambíguos)
overrides = {}
if File.exist?(RENUMBER_FILE)
  File.read(RENUMBER_FILE).each_line do |line|
    next if line.strip.empty? || line.strip.start_with?("#")
    number, filename = line.strip.split("|", 2)
    overrides[filename] = number
  end
end

# Calcula `order` a partir do number dotted
# "1"         → 1_00_00_00 = 1000000
# "1.1"       → 1_01_00_00 = 1010000
# "1.1.1"     → 1_01_01_00 = 1010100
# "1.10.1.2"  → 1_10_01_02 = 1100102
def compute_order(number)
  parts = number.split(".").map(&:to_i)
  parts += [0] * (4 - parts.size) if parts.size < 4
  raise "number has more than 4 levels: #{number}" if parts.size > 4
  parts.each { |p| raise "component > 99: #{number}" if p > 99 }
  parts[0] * 1_000_000 + parts[1] * 10_000 + parts[2] * 100 + parts[3]
end

# Para filenames com prefixo dotted (ex.: "1.1.1 Foo.md"), extrai número + título
# Para filenames "1 Foo.md" (prefixo solto, ambíguo), lê do override
def extract_number_and_title(filename, overrides)
  # Check overrides first (handles ambiguous and collision cases)
  if overrides.key?(filename)
    number = overrides[filename]
    base = filename.sub(/\.md\z/, "")
    title = base.sub(/\A[\d.]+\s+/, "")
    return [number, title]
  end

  base = filename.sub(/\.md\z/, "")
  m = base.match(/\A(\d+(?:\.\d+)+)\s+(.+)\z/)
  if m
    [m[1], m[2]]
  elsif base.match?(/\A\d+\s+/)
    raise "missing override for ambiguous filename: #{filename}"
  else
    raise "cannot parse: #{filename}"
  end
end

Dir.glob("#{PAGES_DIR}/*.md").sort.each do |path|
  filename = File.basename(path)
  content = File.read(path)

  # Separa front matter existente (se houver) do corpo
  if content.start_with?("---\n")
    parts = content.split(/^---\s*$/, 3)
    # parts = ["", "<yaml>", "<body>"]
    body = parts[2].sub(/\A\n/, "")
  else
    body = content
  end

  number, title = extract_number_and_title(filename, overrides)
  order = compute_order(number)

  new_frontmatter = {
    "layout" => "chapter",
    "order"  => order,
    "number" => number,
    "title"  => title,
  }

  new_content = "---\n#{new_frontmatter.to_yaml.sub(/\A---\n/, '')}---\n\n#{body}"
  File.write(path, new_content)
  puts "migrated: #{filename} → #{number} (order #{order})"
end

puts "\nDone. Review diffs with: git diff --stat 100/"
