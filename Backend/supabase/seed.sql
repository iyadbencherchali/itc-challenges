-- Seed file for DispatchDZ

-- 1. wilayas (Full 58 wilayas can be expanded later, providing all 58 is ideal but here is a sample to get started based on the requirements)
INSERT INTO wilayas (id, name_fr, name_ar, code) VALUES
(1, 'Adrar', 'أدرار', '01'),
(2, 'Chlef', 'الشلف', '02'),
(3, 'Laghouat', 'الأغواط', '03'),
(4, 'Oum El Bouaghi', 'أم البواقي', '04'),
(5, 'Batna', 'باتنة', '05'),
(6, 'Béjaïa', 'بجاية', '06'),
(7, 'Biskra', 'بسكرة', '07'),
(8, 'Béchar', 'بشار', '08'),
(9, 'Blida', 'البليدة', '09'),
(10, 'Bouira', 'البويرة', '10'),
(11, 'Tamanrasset', 'تمنراست', '11'),
(12, 'Tébessa', 'تبسة', '12'),
(13, 'Tlemcen', 'تلمسان', '13'),
(14, 'Tiaret', 'تيارت', '14'),
(15, 'Tizi Ouzou', 'تيزي وزو', '15'),
(16, 'Alger', 'الجزائر', '16'),
(17, 'Djelfa', 'الجلفة', '17'),
(18, 'Jijel', 'جيجل', '18'),
(19, 'Sétif', 'سطيف', '19'),
(20, 'Saïda', 'سعيدة', '20'),
(21, 'Skikda', 'سكيكدة', '21'),
(22, 'Sidi Bel Abbès', 'سيدي بلعباس', '22'),
(23, 'Annaba', 'عنابة', '23'),
(24, 'Guelma', 'قالمة', '24'),
(25, 'Constantine', 'قسنطينة', '25'),
(26, 'Médéa', 'المدية', '26'),
(27, 'Mostaganem', 'مستغانم', '27'),
(28, 'M''Sila', 'المسيلة', '28'),
(29, 'Mascara', 'معسكر', '29'),
(30, 'Ouargla', 'ورقلة', '30'),
(31, 'Oran', 'وهران', '31')
-- Add remaining 58 as needed for production
ON CONFLICT (id) DO NOTHING;

-- 2. sectors
INSERT INTO sectors (id, name_fr, name_ar, name_en, icon) VALUES
(1, 'Agroalimentaire', 'الأغذية', 'Food & Produce', '🥕'),
(2, 'Construction', 'البناء', 'Construction', '🏗️'),
(3, 'Pièces détachées', 'قطع الغيار', 'Auto Parts', '⚙️'),
(4, 'Gros / Superettes', 'البيع بالجملة', 'General Wholesale', '📦')
ON CONFLICT (id) DO NOTHING;

-- 3. product_categories
INSERT INTO product_categories (id, sector_id, name_fr, name_ar) VALUES
-- Food
(1, 1, 'Fruits & Légumes', 'فواكه وخضر'),
(2, 1, 'Produits laitiers', 'منتجات الألبان'),
(3, 1, 'Viandes & Volailles', 'لحوم ودواجن'),
-- Construction
(4, 2, 'Ciment & Matériaux', 'إسمنت ومواد البناء'),
(5, 2, 'Câbles & Électricité', 'كابلات وكهرباء'),
(6, 2, 'Plomberie', 'ترصيص'),
-- Auto Parts
(7, 3, 'Filtres & Huiles', 'زيوت وفلاتر'),
(8, 3, 'Pièces Moteur', 'قطع المحرك'),
-- Wholesale
(9, 4, 'Biscuits & Confiseries', 'بسكويت وحلويات'),
(10, 4, 'Boissons', 'مشروبات')
ON CONFLICT (id) DO NOTHING;
