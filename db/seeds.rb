admin = User.find_or_initialize_by(email: "admin@example.com")
admin.assign_attributes(
  password: "admin123",
  password_confirmation: "admin123",
  last_name: "店舗",
  first_name: "管理者",
  role_id: Role::ADMIN_ID
)
admin.save!

categories = {
  "野菜" => 1,
  "果物" => 2,
  "惣菜" => 3,
  "卵" => 4
}.to_h do |name, position|
  category = Category.find_or_initialize_by(name: name)
  category.update!(position: position)
  [name, category]
end

catalog = [
  { category: "野菜", name: "トマト", file: "tomato.jpg", description: "房ごと届く完熟トマトです。", variants: [{ kind: 2, label: "500g", price: 320, stock: 12 }, { kind: 2, label: "1kg", price: 580, stock: 3 }] },
  { category: "野菜", name: "きゅうり", file: "cucumber.jpg", description: "みずみずしいきゅうりです。", variants: [{ kind: 1, label: "3本", price: 180, stock: 0 }, { kind: 1, label: "5本", price: 280, stock: 8 }] },
  { category: "野菜", name: "キャベツ", file: "cabbage.jpg", description: "葉がやわらかいキャベツです。", variants: [{ kind: 1, label: "1玉", price: 250, stock: 6 }] },
  { category: "野菜", name: "にんじん", file: "carrot.jpg", description: "葉つきのにんじんです。", variants: [{ kind: 2, label: "500g", price: 220, stock: 4 }, { kind: 2, label: "1kg", price: 400, stock: 10 }] },
  { category: "野菜", name: "じゃがいも", file: "potato.jpg", description: "煮物にも揚げ物にも使えるじゃがいもです。", variants: [{ kind: 2, label: "1kg", price: 300, stock: 15 }] },
  { category: "野菜", name: "赤玉ねぎ", file: "onion.jpg", description: "甘みのある赤玉ねぎです。", variants: [{ kind: 2, label: "500g", price: 260, stock: 2 }] },
  { category: "野菜", name: "ほうれん草", file: "spinach.jpg", description: "その日の朝に束ねたほうれん草です。", variants: [{ kind: 1, label: "1束", price: 190, stock: 9 }] },
  { category: "野菜", name: "パプリカ", file: "pepper.jpg", description: "赤・黄・オレンジ・緑のパプリカです。", variants: [{ kind: 1, label: "2個", price: 340, stock: 7 }] },
  { category: "野菜", name: "ブロッコリー", file: "broccoli.jpg", description: "つぼみがしまっているブロッコリーです。", variants: [{ kind: 1, label: "1株", price: 280, stock: 0 }] },
  { category: "果物", name: "みかん", file: "orange.jpg", description: "皮がむきやすいみかんです。", variants: [{ kind: 2, label: "1kg", price: 450, stock: 8 }, { kind: 2, label: "2kg", price: 820, stock: 5 }] },
  { category: "果物", name: "りんご", file: "apple.jpg", description: "赤りんごの詰め合わせです。", variants: [{ kind: 1, label: "4個", price: 520, stock: 11 }] },
  { category: "果物", name: "バナナ", file: "banana.jpg", description: "追熟したバナナです。", variants: [{ kind: 1, label: "1房", price: 280, stock: 6 }] },
  { category: "果物", name: "いちご", file: "strawberry.jpg", description: "粒のそろったいちごです。", variants: [{ kind: 1, label: "1パック", price: 680, stock: 3 }] },
  { category: "果物", name: "ぶどう", file: "grape.jpg", description: "房のまま届く黒ぶどうです。", variants: [{ kind: 2, label: "500g", price: 890, stock: 4 }] },
  { category: "果物", name: "洋なし", file: "eggplant.jpg", description: "果肉がやわらかい洋なしです。", variants: [{ kind: 1, label: "2個", price: 420, stock: 5 }] },
  { category: "惣菜", name: "鶏の唐揚げ", file: "fried_chicken.jpg", description: "当日揚げた唐揚げです。", variants: [{ kind: 3, label: "2人前", price: 680, stock: 6 }, { kind: 3, label: "4人前", price: 1280, stock: 2 }] },
  { category: "惣菜", name: "鶏のソテー", file: "croquette.jpg", description: "ハーブをのせた鶏のソテーです。", variants: [{ kind: 3, label: "1人前", price: 740, stock: 8 }] },
  { category: "惣菜", name: "海鮮丼", file: "onigiri.jpg", description: "数種の魚介をのせた丼です。", variants: [{ kind: 3, label: "1人前", price: 1280, stock: 1 }] },
  { category: "惣菜", name: "サラダボウル", file: "salad.jpg", description: "野菜を盛り合わせたサラダです。", variants: [{ kind: 3, label: "1人前", price: 860, stock: 10 }] },
  { category: "卵", name: "卵", file: "egg.jpg", description: "茶色い殻の卵です。", variants: [{ kind: 1, label: "6個", price: 280, stock: 20 }, { kind: 1, label: "10個", price: 430, stock: 12 }] }
]

catalog.each do |entry|
  product = Product.find_or_initialize_by(name: entry[:name])
  product.assign_attributes(category: categories.fetch(entry[:category]), description: entry[:description], published: true)
  File.open(Rails.root.join("db/seed_images", entry[:file]), "rb") do |file|
    product.image.attach(io: file, filename: entry[:file], content_type: "image/jpeg")
    product.save!
  end
  entry[:variants].each do |variant|
    record = product.variants.find_or_initialize_by(label: variant[:label])
    record.update!(option_kind_id: variant[:kind], price: variant[:price], stock: variant[:stock])
  end
end
