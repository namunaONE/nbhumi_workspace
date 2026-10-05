-- HYA-253 (3/4) seed part 3 of 4: municipalities rows 379-567 of 753
-- Idempotent upserts on slug; FK and assertions live in part 4.

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('udayapur-rautamai', 'Udayapur', 'Rautamai', 'रौतामाई', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('udayapur-udayapurgadhi', 'Udayapur', 'Udayapurgadhi', 'उदयपुरगढी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('udayapur-limchungbung', 'Udayapur', 'Limchungbung', 'लिम्चुङबुङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-rajgadh', 'Saptari', 'Rajgadh', 'राजगढ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-rupani', 'Saptari', 'Rupani', 'रुपानी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-tirahut', 'Saptari', 'Tirahut', 'तिराहुत', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-mahadeva', 'Saptari', 'Mahadeva', 'महादेव', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-bishnupur', 'Saptari', 'Bishnupur', 'विष्णुपुर', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-chhinnamasta', 'Saptari', 'Chhinnamasta', 'छिन्नमस्ता', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-balanbihul', 'Saptari', 'Balan Bihul', 'बालन बिहुल', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-tilathikoiladi', 'Saptari', 'Tilathi Koiladi', 'तिलाठी कोइलाडी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-agnisairkrishnasavaran', 'Saptari', 'Agnisair Krishna Savaran', 'अग्निशैर कृष्ण सावरण', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-aurahi', 'Siraha', 'Aurahi', 'औरही', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-naraha', 'Siraha', 'Naraha', 'नरहा', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-arnama', 'Siraha', 'Arnama', 'अर्नामा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-bhagawanpur', 'Siraha', 'Bhagawanpur', 'भगवानपुर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-nawarajpur', 'Siraha', 'Nawarajpur', 'नवराजपुर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-bishnupur', 'Siraha', 'Bishnupur', 'विष्णुपुर', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-bariyarpatti', 'Siraha', 'Bariyarpatti', 'बरियारपट्टी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-laxmipurpatari', 'Siraha', 'Laxmipur Patari', 'लक्ष्मीपुर पटारी', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-sakhuwanankarkatti', 'Siraha', 'Sakhuwanankarkatti', 'सखुवानङ्करकट्टी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-aaurahi', 'Dhanusha', 'Aaurahi', 'औराही', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-dhanauji', 'Dhanusha', 'Dhanauji', 'धनौजी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-bateshwor', 'Dhanusha', 'Bateshwor', 'बटेश्वर', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-janaknandani', 'Dhanusha', 'Janaknandani', 'जनकनन्दनी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-lakshminiya', 'Dhanusha', 'Lakshminiya', 'लक्ष्मीनिया', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-mukhiyapattimusarmiya', 'Dhanusha', 'Mukhiyapatti Musarmiya', 'मुखियापट्टी मुसरमिया', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-pipra', 'Mahottari', 'Pipra', 'पिपरा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-sonama', 'Mahottari', 'Sonama', 'सोनामा', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-samsi', 'Mahottari', 'Samsi', 'सम्सी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-ekdanra', 'Mahottari', 'Ekdanra', 'एकडानरा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-mahottari', 'Mahottari', 'Mahottari', 'महोत्तरी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-dhankaul', 'Sarlahi', 'Dhankaul', 'धनकौल', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-parsa', 'Sarlahi', 'Parsa', 'पर्सा', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-bishnu', 'Sarlahi', 'Bishnu', 'विष्णु', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-ramnagar', 'Sarlahi', 'Ramnagar', 'रामनगर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-kaudena', 'Sarlahi', 'Kaudena', 'कौडेना', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-basbariya', 'Sarlahi', 'Basbariya', 'बासबरिया', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-chandranagar', 'Sarlahi', 'Chandranagar', 'चन्द्रनगर', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-chakraghatta', 'Sarlahi', 'Chakraghatta', 'चक्रघट्टा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-bramhapuri', 'Sarlahi', 'Bramhapuri', 'ब्रम्हपुरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-yemunamai', 'Rautahat', 'Yemunamai', 'यमुनामाई', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-durgabhagwati', 'Rautahat', 'Durga Bhagwati', 'दुर्गा भगवती', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-pheta', 'Bara', 'Pheta', 'फेटा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-devtal', 'Bara', 'Devtal', 'देवताल', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-prasauni', 'Bara', 'Prasauni', 'प्रसौनी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-suwarna', 'Bara', 'Suwarna', 'सुवर्ण', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-baragadhi', 'Bara', 'Baragadhi', 'बारागढी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-karaiyamai', 'Bara', 'Karaiyamai', 'करैयामाई', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-parwanipur', 'Bara', 'Parwanipur', 'परवानीपुर', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-bishrampur', 'Bara', 'Bishrampur', 'बिश्रामपुर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-adarshkotwal', 'Bara', 'Adarsh kotwal', 'आदर्श कोतवाल', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-thori', 'Parsa', 'Thori', 'थोरी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-dhobini', 'Parsa', 'Dhobini', 'धोबिनी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-chhipaharmai', 'Parsa', 'Chhipaharmai', 'छिपहरमाई', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-jirabhawani', 'Parsa', 'Jirabhawani', 'जिरभवानी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-jagarnathpur', 'Parsa', 'Jagarnathpur', 'जगरनाथपुर', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-kalikamai', 'Parsa', 'Kalikamai', 'कालिकामाई', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-bindabasini', 'Parsa', 'Bindabasini', 'बिन्दवासिनी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-pakahamainpur', 'Parsa', 'Pakaha mainpur', 'पकाहा मेनपुर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-sakhuwaprasauni', 'Parsa', 'Sakhuwa Prasauni', 'सखुवा प्रसौनी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-paterwasugauli', 'Parsa', 'Paterwa sugauli', 'पटेरवा सुगौली', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-bigu', 'Dolakha', 'Bigu', 'बिगु', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-sailung', 'Dolakha', 'Sailung', 'सेलुङ', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-melung', 'Dolakha', 'Melung', 'मेलुङ', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-baiteshwor', 'Dolakha', 'Baiteshwor', 'बैतेश्वर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-tamakoshi', 'Dolakha', 'Tamakoshi', 'तामाकोशी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-gaurishankar', 'Dolakha', 'Gaurishankar', 'गौरीशंकर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-kalinchok', 'Dolakha', 'Kalinchok', 'कालिञ्चोक', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-jugal', 'Sindhupalchok', 'Jugal', 'जुगल', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-balefi', 'Sindhupalchok', 'Balefi', 'बलेफी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-sunkoshi', 'Sindhupalchok', 'Sunkoshi', 'सुनकोशी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-helambu', 'Sindhupalchok', 'Helambu', 'हेलम्बु', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-bhotekoshi', 'Sindhupalchok', 'Bhotekoshi', 'भोटेकोशी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-lisangkhu', 'Sindhupalchok', 'Lisangkhu', 'लिसाङ्खु', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-indrawati', 'Sindhupalchok', 'Indrawati', 'इन्द्रावती', 'rural_municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-tripurasundari', 'Sindhupalchok', 'Tripurasundari', 'त्रिपुरासुन्दरी', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-panchpokharithangpal', 'Sindhupalchok', 'Panchpokhari Thangpal', 'पाँचपोखरी थाङ्पाल', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rasuwa-kalika', 'Rasuwa', 'Kalika', 'कालिका', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rasuwa-naukunda', 'Rasuwa', 'Naukunda', 'नौकुण्ड', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rasuwa-uttargaya', 'Rasuwa', 'Uttargaya', 'उत्तरगया', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rasuwa-gosaikunda', 'Rasuwa', 'Gosaikunda', 'गोसाइकुण्ड', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rasuwa-amachodingmo', 'Rasuwa', 'Amachodingmo', 'अमाकोडिङमो', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-gajuri', 'Dhading', 'Gajuri', 'गजुरी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-galchi', 'Dhading', 'Galchi', 'गाल्ची', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-thakre', 'Dhading', 'Thakre', 'ठाकरे', 'rural_municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-siddhalek', 'Dhading', 'Siddhalek', 'सिद्धलेक', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-khaniyabash', 'Dhading', 'Khaniyabash', 'खनियाबास', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-jwalamukhi', 'Dhading', 'Jwalamukhi', 'ज्वालामुखी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-gangajamuna', 'Dhading', 'Gangajamuna', 'गंगाजमुना', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-rubivalley', 'Dhading', 'Rubi Valley', 'रुबी उपत्यका', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-tripurasundari', 'Dhading', 'Tripura Sundari', 'त्रिपुरा सुन्दरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-netrawatidabjong', 'Dhading', 'Netrawati Dabjong', 'नेत्रावती डब्जोङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-benighatrorang', 'Dhading', 'Benighat Rorang', 'बेनिघाट रोराङ', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-kakani', 'Nuwakot', 'Kakani', 'ककनी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-tadi', 'Nuwakot', 'Tadi', 'ताडी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-likhu', 'Nuwakot', 'Likhu', 'लिखु', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-myagang', 'Nuwakot', 'Myagang', 'म्यागाङ', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-shivapuri', 'Nuwakot', 'Shivapuri', 'शिवपुरी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-kispang', 'Nuwakot', 'Kispang', 'किस्पाङ', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-suryagadhi', 'Nuwakot', 'Suryagadhi', 'सुर्यगढी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-tarkeshwar', 'Nuwakot', 'Tarkeshwar', 'तारकेश्वर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-panchakanya', 'Nuwakot', 'Panchakanya', 'पञ्चकन्या', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-dupcheshwar', 'Nuwakot', 'Dupcheshwar', 'दुप्चेश्वर', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lalitpur-bagmati', 'Lalitpur', 'Bagmati', 'बागमती', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lalitpur-mahankal', 'Lalitpur', 'Mahankal', 'महांकाल', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lalitpur-konjyosom', 'Lalitpur', 'Konjyosom', 'कोन्ज्योसोम', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-roshi', 'Kavrepalanchok', 'Roshi', 'रोशी', 'rural_municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-temal', 'Kavrepalanchok', 'Temal', 'तेमल', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-bhumlu', 'Kavrepalanchok', 'Bhumlu', 'भुम्लु', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-mahabharat', 'Kavrepalanchok', 'Mahabharat', 'महाभारत', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-bethanchowk', 'Kavrepalanchok', 'Bethanchowk', 'बेथानचोक', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-khanikhola', 'Kavrepalanchok', 'Khanikhola', 'खानीखोला', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-chaurideurali', 'Kavrepalanchok', 'Chaurideurali', 'चौरीदेउराली', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ramechhap-sunapati', 'Ramechhap', 'Sunapati', 'सुनापति', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ramechhap-doramba', 'Ramechhap', 'Doramba', 'दोरम्बा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ramechhap-umakunda', 'Ramechhap', 'Umakunda', 'उमाकुण्ड', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ramechhap-khadadevi', 'Ramechhap', 'Khadadevi', 'खाडादेवी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ramechhap-gokulganga', 'Ramechhap', 'Gokulganga', 'गोकुलगंगा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ramechhap-likhutamakoshi', 'Ramechhap', 'Likhu Tamakoshi', 'लिखु तामाकोशी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-marin', 'Sindhuli', 'Marin', 'मारिन', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-phikkal', 'Sindhuli', 'Phikkal', 'फिक्कल', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-tinpatan', 'Sindhuli', 'Tinpatan', 'तिनपाटन', 'rural_municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-sunkoshi', 'Sindhuli', 'Sunkoshi', 'सुनकोशी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-golanjor', 'Sindhuli', 'Golanjor', 'गोलन्जोर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-ghanglekh', 'Sindhuli', 'Ghanglekh', 'घाङ्लेख', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-hariharpurgadhi', 'Sindhuli', 'Hariharpurgadhi', 'हरिहरपुरगढी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-bakaiya', 'Makwanpur', 'Bakaiya', 'बकैया', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-kailash', 'Makwanpur', 'Kailash', 'कैलाश', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-manahari', 'Makwanpur', 'Manahari', 'मनहरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-bhimphedi', 'Makwanpur', 'Bhimphedi', 'भीमफेदी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-bagmati', 'Makwanpur', 'Bagmati', 'बागमती', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-raksirang', 'Makwanpur', 'Raksirang', 'रक्सिराङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-makawanpurgadhi', 'Makwanpur', 'Makawanpurgadhi', 'मकवानपुरगढी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-indrasarowar', 'Makwanpur', 'Indrasarowar', 'इन्द्रसरोवर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('chitwan-ichchhyakamana', 'Chitwan', 'Ichchhyakamana', 'इच्छाकामना', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-gandaki', 'Gorkha', 'Gandaki', 'गण्डकी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-dharche', 'Gorkha', 'Dharche', 'धार्चे', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-aarughat', 'Gorkha', 'Aarughat', 'आरुघाट', 'rural_municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-ajirkot', 'Gorkha', 'Ajirkot', 'अजिरकोट', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-sahidlakhan', 'Gorkha', 'Sahid Lakhan', 'सहिद लखन', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-siranchok', 'Gorkha', 'Siranchok', 'सिरञ्चोक', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-bhimsenthapa', 'Gorkha', 'Bhimsenthapa', 'भीमसेनथापा', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-chumnubri', 'Gorkha', 'Chum Nubri', 'चुम नुब्रि', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-barpaksulikot', 'Gorkha', 'Barpak Sulikot', 'बारपाक सुलिकोट', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('manang-chame', 'Manang', 'Chame', 'चामे', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('manang-narshon', 'Manang', 'Narshon', 'नरशोन', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('manang-narpabhumi', 'Manang', 'Narpa Bhumi', 'नरपा भूमि', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('manang-manangingshyang', 'Manang', 'Manang Ingshyang', 'मनाङ इङ्स्याङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mustang-thasang', 'Mustang', 'Thasang', 'थासाङ', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mustang-gharapjhong', 'Mustang', 'Gharapjhong', 'घरापझोङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mustang-lomanthang', 'Mustang', 'Lomanthang', 'लोमान्थाङ', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mustang-loghekardamodarkunda', 'Mustang', 'Lo-Ghekar Damodarkunda', 'लो घेकर दामोदरकुण्ड', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mustang-waragungmuktikhsetra', 'Mustang', 'Waragung Muktikhsetra', 'वारागुङ मुक्तिक्षेत्र', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('myagdi-mangala', 'Myagdi', 'Mangala', 'मंगला', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('myagdi-malika', 'Myagdi', 'Malika', 'मलिका', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('myagdi-raghuganga', 'Myagdi', 'Raghuganga', 'रघुगंगा', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('myagdi-dhaulagiri', 'Myagdi', 'Dhaulagiri', 'धौलागिरी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('myagdi-annapurna', 'Myagdi', 'Annapurna', 'अन्नपूर्ण', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kaski-rupa', 'Kaski', 'Rupa', 'रुपा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kaski-madi', 'Kaski', 'Madi', 'माडी', 'rural_municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kaski-annapurna', 'Kaski', 'Annapurna', 'अन्नपूर्ण', 'rural_municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kaski-machhapuchchhre', 'Kaski', 'Machhapuchchhre', 'माछापुच्छ्रे', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lamjung-dordi', 'Lamjung', 'Dordi', 'दोर्दी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lamjung-dudhpokhari', 'Lamjung', 'Dudhpokhari', 'दूधपोखरी', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lamjung-marsyangdi', 'Lamjung', 'Marsyangdi', 'मर्स्याङ्दी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lamjung-kwholasothar', 'Lamjung', 'Kwholasothar', 'क्वालासोथर', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-ghiring', 'Tanahun', 'Ghiring', 'घिरिङ', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-devghat', 'Tanahun', 'Devghat', 'देवघाट', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-rhishing', 'Tanahun', 'Rhishing', 'रिसिङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-myagde', 'Tanahun', 'Myagde', 'म्याग्दे', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-bandipur', 'Tanahun', 'Bandipur', 'बन्दीपुर', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-anbukhaireni', 'Tanahun', 'Anbukhaireni', 'अन्बुखैरेनी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasieast-baudeekali', 'Nawalparasi East', 'Baudeekali', 'बौदेकाली', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasieast-bulingtar', 'Nawalparasi East', 'Bulingtar', 'बुलिङटार', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasieast-hupsekot', 'Nawalparasi East', 'Hupsekot', 'हुप्सेकोट', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasieast-binayee', 'Nawalparasi East', 'Binayee', 'बिनयी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-harinas', 'Syangja', 'Harinas', 'हरिनास', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-biruwa', 'Syangja', 'Biruwa', 'बिरुवा', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-aandhikhola', 'Syangja', 'Aandhikhola', 'आँधीखोला', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-phedikhola', 'Syangja', 'Phedikhola', 'फेदीखोला', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-kaligandagi', 'Syangja', 'Kaligandagi', 'कालीगण्डगी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-arjunchaupari', 'Syangja', 'Arjunchaupari', 'अर्जुनचौपरी', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parbat-modi', 'Parbat', 'Modi', 'मोदी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parbat-painyu', 'Parbat', 'Painyu', 'पाइन्यु', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parbat-jaljala', 'Parbat', 'Jaljala', 'जलजला', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parbat-bihadi', 'Parbat', 'Bihadi', 'बिहादी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parbat-mahashila', 'Parbat', 'Mahashila', 'महाशिला', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-bareng', 'Baglung', 'Bareng', 'बरेङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;
