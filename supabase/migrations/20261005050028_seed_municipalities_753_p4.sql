-- HYA-253 (3/4) seed part 4 of 4: municipalities rows 568-753 of 753
-- Idempotent upserts on slug; FK and assertions live in part 4.

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-badigad', 'Baglung', 'Badigad', 'बडिगाड', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-nisikhola', 'Baglung', 'Nisikhola', 'निसिखोला', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-kanthekhola', 'Baglung', 'Kanthekhola', 'कान्ठेखोला', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-tarakhola', 'Baglung', 'Tara Khola', 'तारा खोला', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-tamankhola', 'Baglung', 'Taman Khola', 'तमन खोला', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumeast-bhume', 'Rukum East', 'Bhume', 'भुमे', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumeast-sisne', 'Rukum East', 'Sisne', 'सिस्ने', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumeast-puthauttarganga', 'Rukum East', 'Putha Uttarganga', 'पुथा उत्तरगंगा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-madi', 'Rolpa', 'Madi', 'माडी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-thawang', 'Rolpa', 'Thawang', 'थवाङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-sunchhahari', 'Rolpa', 'Sunchhahari', 'सुनछहरी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-lungri', 'Rolpa', 'Lungri', 'लुङ्गरी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-gangadev', 'Rolpa', 'Gangadev', 'गंगादेव', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-tribeni', 'Rolpa', 'Tribeni', 'त्रिवेणी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-pariwartan', 'Rolpa', 'Pariwartan', 'परिवर्तन', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-runtigadi', 'Rolpa', 'Runtigadi', 'रुन्टीगढी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-sunilsmriti', 'Rolpa', 'Sunil Smriti', 'सुनिल स्मृति', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-ayirabat', 'Pyuthan', 'Ayirabat', 'आइराबत', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-gaumukhi', 'Pyuthan', 'Gaumukhi', 'गौमुखी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-jhimruk', 'Pyuthan', 'Jhimruk', 'झिमरुक', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-naubahini', 'Pyuthan', 'Naubahini', 'नौबहिनी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-mandavi', 'Pyuthan', 'Mandavi', 'मांडवी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-mallarani', 'Pyuthan', 'Mallarani', 'मल्लरानी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-sarumarani', 'Pyuthan', 'Sarumarani', 'सरूमरानी', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-rurukshetra', 'Gulmi', 'Rurukshetra', 'रुरु', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-ishma', 'Gulmi', 'Ishma', 'इस्मा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-madane', 'Gulmi', 'Madane', 'मदने', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-malika', 'Gulmi', 'Malika', 'मलिका', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-chhatrakot', 'Gulmi', 'Chhatrakot', 'चत्रकोट', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-dhurkot', 'Gulmi', 'Dhurkot', 'चत्रकोट', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-satyawati', 'Gulmi', 'Satyawati', 'सत्यवती', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-chandrakot', 'Gulmi', 'Chandrakot', 'चन्द्रकोट', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-kaligandaki', 'Gulmi', 'Kaligandaki', 'कालीगण्डकी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-gulmidarbar', 'Gulmi', 'Gulmidarbar', 'गुल्मीदरबार', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('arghakhanchi-panini', 'Arghakhanchi', 'Panini', 'पाणिनी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('arghakhanchi-chhatradev', 'Arghakhanchi', 'Chhatradev', 'छत्रदेव', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('arghakhanchi-malarani', 'Arghakhanchi', 'Malarani', 'मलारानी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-rambha', 'Palpa', 'Rambha', 'रम्भा', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-tinau', 'Palpa', 'Tinau', 'तिनाउ', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-nisdi', 'Palpa', 'Nisdi', 'निस्दी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-mathagadhi', 'Palpa', 'Mathagadhi', 'मठगढी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-ribdikot', 'Palpa', 'Ribdikot', 'रिब्दीकोट', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-purbakhola', 'Palpa', 'Purbakhola', 'पूर्वखोला', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-bagnaskali', 'Palpa', 'Bagnaskali', 'बागनास्कली', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-rainadevi', 'Palpa', 'Rainadevi', 'रैनादेवी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasiwest-sarawal', 'Nawalparasi West', 'Sarawal', 'सरवल', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasiwest-susta', 'Nawalparasi West', 'Susta', 'सुस्ता', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasiwest-pratappur', 'Nawalparasi West', 'Pratappur', 'प्रतापपुर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasiwest-palhinandan', 'Nawalparasi West', 'Palhi Nandan', 'पाल्ही नन्दन', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-kanchan', 'Rupandehi', 'Kanchan', 'कञ्चन', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-siyari', 'Rupandehi', 'Siyari', 'सियारी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-rohini', 'Rupandehi', 'Rohini', 'रोहिणी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-gaidahawa', 'Rupandehi', 'Gaidahawa', 'गैडहवा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-omsatiya', 'Rupandehi', 'Omsatiya', 'ओमसतिया', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-sudhdhodhan', 'Rupandehi', 'Sudhdhodhan', 'शुद्धोधन', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-mayadevi', 'Rupandehi', 'Mayadevi', 'मायादेवी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-marchawari', 'Rupandehi', 'Marchawari', 'मार्चवारी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-kotahimai', 'Rupandehi', 'Kotahimai', 'कोटाहिमाई', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-sammarimai', 'Rupandehi', 'Sammarimai', 'समरीमाई', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-yashodhara', 'Kapilvastu', 'Yashodhara', 'यशोधरा', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-bijayanagar', 'Kapilvastu', 'Bijayanagar', 'विजयनगर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-mayadevi', 'Kapilvastu', 'Mayadevi', 'मायादेवी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-suddhodhan', 'Kapilvastu', 'Suddhodhan', 'शुद्धोधन', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-babai', 'Dang', 'Babai', 'बबई', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-gadhawa', 'Dang', 'Gadhawa', 'गढवा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-rapti', 'Dang', 'Rapti', 'राप्ती', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-rajpur', 'Dang', 'Rajpur', 'राजपुर', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-dangisharan', 'Dang', 'Dangisharan', 'दंगिशरण', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-shantinagar', 'Dang', 'Shantinagar', 'शान्तिनगर', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-banglachuli', 'Dang', 'Banglachuli', 'बंगलाचुली', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('banke-khajura', 'Banke', 'Khajura', 'खजुरा', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('banke-janki', 'Banke', 'Janki', 'जानकी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('banke-baijanath', 'Banke', 'Baijanath', 'बैजनाथ', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('banke-duduwa', 'Banke', 'Duduwa', 'डुडुवा', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('banke-narainapur', 'Banke', 'Narainapur', 'नरैनापुर', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('banke-raptisonari', 'Banke', 'Rapti Sonari', 'राप्ती सोनारी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bardiya-geruwa', 'Bardiya', 'Geruwa', 'गेरुवा', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bardiya-badhaiyatal', 'Bardiya', 'Badhaiyatal', 'बढैयाताल', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolpa-kaike', 'Dolpa', 'Kaike', 'काइके', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolpa-jagadulla', 'Dolpa', 'Jagadulla', 'जगदुल्ला', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolpa-mudkechula', 'Dolpa', 'Mudkechula', 'मुड्केचुला', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolpa-dolpobuddha', 'Dolpa', 'Dolpo Buddha', 'डोल्पो बुद्ध', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolpa-sheyphoksundo', 'Dolpa', 'Shey Phoksundo', 'शे फोक्सुण्डो', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolpa-chharkatangsong', 'Dolpa', 'Chharka Tangsong', 'छर्का ताङसोङ', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mugu-soru', 'Mugu', 'Soru', 'सोरु', 'rural_municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mugu-khatyad', 'Mugu', 'Khatyad', 'खत्याड', 'rural_municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mugu-mugumkarmarong', 'Mugu', 'Mugum Karmarong', 'मुगुम कर्मारोङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('humla-simkot', 'Humla', 'Simkot', 'सिमकोट', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('humla-namkha', 'Humla', 'Namkha', 'नम्खा', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('humla-chankheli', 'Humla', 'Chankheli', 'चनखेली', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('humla-tanjakot', 'Humla', 'Tanjakot', 'तान्जाकोट', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('humla-sarkegad', 'Humla', 'Sarkegad', 'सार्केगड', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('humla-adanchuli', 'Humla', 'Adanchuli', 'अडांचुली', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('humla-kharpunath', 'Humla', 'Kharpunath', 'खार्पुनाथ', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jumla-hima', 'Jumla', 'Hima', 'हिमा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jumla-tila', 'Jumla', 'Tila', 'तिला', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jumla-sinja', 'Jumla', 'Sinja', 'सिन्जा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jumla-guthichaur', 'Jumla', 'Guthichaur', 'गुठीचौर', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jumla-tatopani', 'Jumla', 'Tatopani', 'तातोपानी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jumla-patrasi', 'Jumla', 'Patrasi', 'पत्रासी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jumla-kanakasundari', 'Jumla', 'Kanakasundari', 'कनकसुन्दरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-mahawai', 'Kalikot', 'Mahawai', 'महावाई', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-palata', 'Kalikot', 'Palata', 'पलाता', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-naraharinath', 'Kalikot', 'Naraharinath', 'नरहरिनाथ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-pachaljharana', 'Kalikot', 'Pachaljharana', 'पाँचलझरना', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-subhakalika', 'Kalikot', 'Subha Kalika', 'शुभ कालिका', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-sannitribeni', 'Kalikot', 'Sanni Tribeni', 'सन्नी त्रिवेणी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-bhairabi', 'Dailekh', 'Bhairabi', 'भैरवी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-mahabu', 'Dailekh', 'Mahabu', 'महाबु', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-gurans', 'Dailekh', 'Gurans', 'गुराँस', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-naumule', 'Dailekh', 'Naumule', 'नौमुले', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-bhagawatimai', 'Dailekh', 'Bhagawatimai', 'भगवतीमाई', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-thantikandh', 'Dailekh', 'Thantikandh', 'ठान्टिकाण्ड', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-dungeshwor', 'Dailekh', 'Dungeshwor', 'डुङ्गेश्वर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jajarkot-kuse', 'Jajarkot', 'Kuse', 'कुसे', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jajarkot-shiwalaya', 'Jajarkot', 'Shiwalaya', 'शिवालय', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jajarkot-barekot', 'Jajarkot', 'Barekot', 'बारेकोट', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jajarkot-junichande', 'Jajarkot', 'Junichande', 'जुनिचन्दे', 'rural_municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumwest-tribeni', 'Rukum West', 'Tribeni', 'त्रिवेणी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumwest-sanibheri', 'Rukum West', 'Sani Bheri', 'सानी भेरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumwest-banfikot', 'Rukum West', 'Banfikot', 'बनफिकोट', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-kumakh', 'Salyan', 'Kumakh', 'कुमाख', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-darma', 'Salyan', 'Darma', 'डार्मा', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-kapurkot', 'Salyan', 'Kapurkot', 'कपुरकोट', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-kalimati', 'Salyan', 'Kalimati', 'कालीमाटी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-tribeni', 'Salyan', 'Tribeni', 'त्रिवेणी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-chhatreshwori', 'Salyan', 'Chhatreshwori', 'छत्रेश्वरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-siddhakumakh', 'Salyan', 'Siddha Kumakh', 'सिद्ध कुमाख', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-chaukune', 'Surkhet', 'Chaukune', 'चौकुने', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-simta', 'Surkhet', 'Simta', 'सिम्ता', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-chingad', 'Surkhet', 'Chingad', 'चिंगाड', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-barahtal', 'Surkhet', 'Barahtal', 'बराहताल', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-gaumul', 'Bajura', 'Gaumul', 'गौमुल', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-himali', 'Bajura', 'Himali', 'हिमाली', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-jagannath', 'Bajura', 'Jagannath', 'जगन्नाथ', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-khaptadchhededaha', 'Bajura', 'Khaptad Chhededaha', 'खप्तड छेडेदह', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-swamikartikkhaapar', 'Bajura', 'Swami Kartik Khaapar', 'स्वामी कार्तिक खापर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-masta', 'Bajhang', 'Masta', 'मस्त', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-thalara', 'Bajhang', 'Thalara', 'थालारा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-talkot', 'Bajhang', 'Talkot', 'तालकोट', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-surma', 'Bajhang', 'Surma', 'सुर्मा', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-saipaal', 'Bajhang', 'SaiPaal', 'साइपाल', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-durgathali', 'Bajhang', 'Durgathali', 'दुर्गाथली', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-bithadchir', 'Bajhang', 'Bithadchir', 'बिठाडचिर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-kedarseu', 'Bajhang', 'Kedarseu', 'केदारसेउ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-khaptadchhanna', 'Bajhang', 'Khaptadchhanna', 'खप्तडछन्ना', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-chabispathivera', 'Bajhang', 'Chabispathivera', 'चाबिस्पाथीवेरा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-lekam', 'Darchula', 'Lekam', 'लेकम', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-naugad', 'Darchula', 'Naugad', 'नौगाड', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-byas', 'Darchula', 'Byas', 'ब्यास', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-dunhu', 'Darchula', 'Dunhu', 'दुन्हु', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-marma', 'Darchula', 'Marma', 'मर्मा', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-apihimal', 'Darchula', 'Apihimal', 'एपिहिमल', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-malikaarjun', 'Darchula', 'Malikaarjun', 'मालिकार्जुन', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-sigas', 'Baitadi', 'Sigas', 'सिगास', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-shivanath', 'Baitadi', 'Shivanath', 'शिवनाथ', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-surnaya', 'Baitadi', 'Surnaya', 'सुर्नाया', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-dilasaini', 'Baitadi', 'Dilasaini', 'डिलासैनी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-pancheshwar', 'Baitadi', 'Pancheshwar', 'पञ्चेश्वर', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-dogadakedar', 'Baitadi', 'Dogadakedar', 'दोगडाकेदार', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dadeldhura-alital', 'Dadeldhura', 'Alital', 'अलिताल', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dadeldhura-ajaymeru', 'Dadeldhura', 'Ajaymeru', 'अजयमेरु', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dadeldhura-bhageshwar', 'Dadeldhura', 'Bhageshwar', 'भागेश्वर', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dadeldhura-nawadurga', 'Dadeldhura', 'Nawadurga', 'नवदुर्गा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dadeldhura-ganayapdhura', 'Dadeldhura', 'Ganayapdhura', 'गणयपधुरा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-sayal', 'Doti', 'Sayal', 'सायल', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-adharsha', 'Doti', 'Adharsha', 'आदर्श', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-jorayal', 'Doti', 'Jorayal', 'जोरयाल', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-badikedar', 'Doti', 'Badikedar', 'बडीकेदार', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-purbichauki', 'Doti', 'Purbichauki', 'पूर्वचौकी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-kisingh', 'Doti', 'K I Singh', 'के आई सिंह', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-bogtanfoodsil', 'Doti', 'Bogtan Foodsil', 'Bogtan Foodsil', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-dhakari', 'Achham', 'Dhakari', 'ढकारी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-mellekh', 'Achham', 'Mellekh', 'मेल्लेख', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-chaurpati', 'Achham', 'Chaurpati', 'चौरपाटी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-ramaroshan', 'Achham', 'Ramaroshan', 'रामरोशन', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-turmakhad', 'Achham', 'Turmakhad', 'तुर्मखाड', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-bannigadhi', 'Achham', 'Bannigadhi', 'बान्नीगढी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-chure', 'Kailali', 'Chure', 'चुरे', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-janaki', 'Kailali', 'Janaki', 'जानकी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-kailari', 'Kailali', 'Kailari', 'कैलारी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-joshipur', 'Kailali', 'Joshipur', 'जोशीपुर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-mohanyal', 'Kailali', 'Mohanyal', 'मोहन्याल', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-bardagoriya', 'Kailali', 'Bardagoriya', 'बर्दगोरिया', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-beldandi', 'Kanchanpur', 'Beldandi', 'बेलडाँडी', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-laljhandi', 'Kanchanpur', 'Laljhandi', 'लालझण्डी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;
-- ---------------------------------------------------------------------------
-- Reference integrity: city must name a municipality in the listing's district
-- ---------------------------------------------------------------------------

alter table public.listings
  add constraint listings_city_fkey
  foreign key (district, city)
  references public.municipalities (district, name);

-- ---------------------------------------------------------------------------
-- Assertions: the seed is exactly the 753 it claims to be
-- ---------------------------------------------------------------------------

do $$
declare
  v_total integer;
  v_metro integer;
  v_sub integer;
  v_muni integer;
  v_rural integer;
  v_districts integer;
begin
  select count(*) into v_total from public.municipalities;
  if v_total <> 753 then
    raise exception 'SEED MISMATCH: % municipalities, expected 753', v_total
      using errcode = 'integrity_constraint_violation';
  end if;

  select count(*) into v_metro from public.municipalities where type = 'metropolitan';
  select count(*) into v_sub from public.municipalities where type = 'sub_metropolitan';
  select count(*) into v_muni from public.municipalities where type = 'municipality';
  select count(*) into v_rural from public.municipalities where type = 'rural_municipality';
  if v_metro <> 6 or v_sub <> 11 or v_muni <> 276 or v_rural <> 460 then
    raise exception 'SEED MISMATCH: types %/%/%/%, expected 6/11/276/460',
      v_metro, v_sub, v_muni, v_rural
      using errcode = 'integrity_constraint_violation';
  end if;

  select count(distinct district) into v_districts from public.municipalities;
  if v_districts <> 77 then
    raise exception 'SEED MISMATCH: % districts covered, expected 77', v_districts
      using errcode = 'integrity_constraint_violation';
  end if;

  raise notice 'municipality seed ok: 753 rows, 6/11/276/460, 77 districts';
end;
$$;