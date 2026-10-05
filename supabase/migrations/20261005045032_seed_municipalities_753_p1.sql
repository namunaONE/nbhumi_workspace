-- HYA-253 (3/4) seed part 1 of 4: municipalities rows 1-189 of 753
-- Idempotent upserts on slug; FK and assertions live in part 4.

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kaski-pokhara', 'Kaski', 'Pokhara', 'पोखरा', 'metropolitan'::public.municipality_type, 33) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('chitwan-bharatpur', 'Chitwan', 'Bharatpur', 'भरतपुर', 'metropolitan'::public.municipality_type, 29) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-birgunj', 'Parsa', 'Birgunj', 'वीरगन्ज', 'metropolitan'::public.municipality_type, 32) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-biratnagar', 'Morang', 'Biratnagar', 'विराटनगर', 'metropolitan'::public.municipality_type, 19) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-kathmandu', 'Kathmandu', 'Kathmandu', 'काठमाडौं ।', 'metropolitan'::public.municipality_type, 32) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lalitpur-lalitpur', 'Lalitpur', 'Lalitpur', 'ललितपुर', 'metropolitan'::public.municipality_type, 29) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-ghorahi', 'Dang', 'Ghorahi', 'घोराही', 'sub_metropolitan'::public.municipality_type, 19) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-tulsipur', 'Dang', 'Tulsipur', 'तुलसीपुर', 'sub_metropolitan'::public.municipality_type, 19) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-jitpursimara', 'Bara', 'Jitpursimara', 'जितपुरसिमारा', 'sub_metropolitan'::public.municipality_type, 24) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-dhangadhi', 'Kailali', 'Dhangadhi', 'धनगढी', 'sub_metropolitan'::public.municipality_type, 19) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-hetauda', 'Makwanpur', 'Hetauda', 'हेटौंडा', 'sub_metropolitan'::public.municipality_type, 19) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-dharan', 'Sunsari', 'Dharan', 'धरान', 'sub_metropolitan'::public.municipality_type, 20) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-kalaiya', 'Bara', 'Kalaiya', 'कलैया', 'sub_metropolitan'::public.municipality_type, 27) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-butwal', 'Rupandehi', 'Butwal', 'बुटवल', 'sub_metropolitan'::public.municipality_type, 19) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-itahari', 'Sunsari', 'Itahari', 'इटहरी', 'sub_metropolitan'::public.municipality_type, 20) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-janakpurdham', 'Dhanusha', 'Janakpurdham', 'जनकपुरधाम', 'sub_metropolitan'::public.municipality_type, 25) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('banke-nepalgunj', 'Banke', 'Nepalgunj', 'नेपालगन्ज', 'sub_metropolitan'::public.municipality_type, 23) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-phungling', 'Taplejung', 'Phungling', 'फुङ्लिङ', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-dharmadevi', 'Sankhuwasabha', 'Dharmadevi', 'धर्मदेवी', 'municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-madi', 'Sankhuwasabha', 'Madi', 'माडी', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-panchakhapan', 'Sankhuwasabha', 'Panchakhapan', 'पञ्चखापन', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-chainpur', 'Sankhuwasabha', 'Chainpur', 'चैनपुर', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-khandbari', 'Sankhuwasabha', 'Khandbari', 'खाँदबारी', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('solukhumbu-solududhakunda', 'Solukhumbu', 'Solududhakunda', 'सोलुदुधाकुण्ड', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('okhaldhunga-siddhicharan', 'Okhaldhunga', 'Siddhicharan', 'सिद्धिचरण', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-halesituwachung', 'Khotang', 'Halesi Tuwachung', 'हलेसी तुवाचुङ', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-diktelrupakotmajhuwagadhi', 'Khotang', 'Diktel Rupakot Majhuwagadhi', 'दिक्तेल रुपाकोट मझुवागढी', 'municipality'::public.municipality_type, 15) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-shadananda', 'Bhojpur', 'Shadananda', 'षडानन्द', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-bhojpur', 'Bhojpur', 'Bhojpur', 'भोजपुर', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhankuta-pakhribas', 'Dhankuta', 'Pakhribas', 'पाखरिबास', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhankuta-mahalaxmi', 'Dhankuta', 'Mahalaxmi', 'महालक्ष्मी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhankuta-dhankuta', 'Dhankuta', 'Dhankuta', 'धनकुटा', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('terhathum-laligurans', 'Terhathum', 'Laligurans', 'लालीगुराँस', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('terhathum-myanglung', 'Terhathum', 'Myanglung', 'म्याङलुङ', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('panchthar-phidim', 'Panchthar', 'Phidim', 'फिदिम', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-illam', 'Ilam', 'Illam', 'इलाम', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-mai', 'Ilam', 'Mai', 'माई', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-deumai', 'Ilam', 'Deumai', 'देउमाई', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-suryodaya', 'Ilam', 'Suryodaya', 'सूर्योदय', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-shivasataxi', 'Jhapa', 'Shivasataxi', 'शिवसताक्सी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-bhadrapur', 'Jhapa', 'Bhadrapur', 'भद्रपुर', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-kankai', 'Jhapa', 'Kankai', 'कनकाई', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-birtamod', 'Jhapa', 'Birtamod', 'बिर्तामोड', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-mechinagar', 'Jhapa', 'Mechinagar', 'मेचीनगर', 'municipality'::public.municipality_type, 15) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-damak', 'Jhapa', 'Damak', 'दमक', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-arjundhara', 'Jhapa', 'Arjundhara', 'अर्जुनधारा', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-gauradhaha', 'Jhapa', 'Gauradhaha', 'गौराधा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-letang', 'Morang', 'Letang', 'लेटाङ', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-sunwarshi', 'Morang', 'Sunwarshi', 'सुनवर्शी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-rangeli', 'Morang', 'Rangeli', 'रंगेली', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-patharishanishchare', 'Morang', 'Pathari Shanishchare', 'पथरी शनिश्चरे', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-uralabari', 'Morang', 'Uralabari', 'उरालाबारी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-belbari', 'Morang', 'Belbari', 'बेलबारी', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-sundarharaicha', 'Morang', 'Sundarharaicha', 'सुन्दरहरैचा', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-ratuwamai', 'Morang', 'Ratuwamai', 'रतुवामाई', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-ramdhuni', 'Sunsari', 'Ramdhuni', 'रामधुनी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-barahchhetra', 'Sunsari', 'Barahchhetra', 'बराहक्षेत्र', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-duhabi', 'Sunsari', 'Duhabi', 'दुहबी', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-inaruwa', 'Sunsari', 'Inaruwa', 'इनरुवा', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('udayapur-triyuga', 'Udayapur', 'Triyuga', 'त्रियुग', 'municipality'::public.municipality_type, 16) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('udayapur-katari', 'Udayapur', 'Katari', 'कटारी', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('udayapur-chaudandigadhi', 'Udayapur', 'Chaudandigadhi', 'चौदण्डीगढी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('udayapur-belaka', 'Udayapur', 'Belaka', 'बेलका', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-hanumannagarkankalini', 'Saptari', 'Hanumannagar Kankalini', 'हनुमाननगर कंकालिनी', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-kanchanrup', 'Saptari', 'Kanchanrup', 'कञ्चनरुप', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-rajbiraj', 'Saptari', 'Rajbiraj', 'राजविराज', 'municipality'::public.municipality_type, 16) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-khadak', 'Saptari', 'Khadak', 'खडक', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-dakneshwori', 'Saptari', 'Dakneshwori', 'डाक्नेश्वरी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-saptakoshi', 'Saptari', 'Saptakoshi', 'सप्तकोशी', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-surunga', 'Saptari', 'Surunga', 'सुरुङ्गा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-shambhunath', 'Saptari', 'Shambhunath', 'शम्भुनाथ', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('saptari-bodebarsain', 'Saptari', 'Bode Barsain', 'बोडे बार्सैन', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-mirchaiya', 'Siraha', 'Mirchaiya', 'मिर्चैया', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-lahan', 'Siraha', 'Lahan', 'लहान', 'municipality'::public.municipality_type, 24) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-siraha', 'Siraha', 'Siraha', 'सिरहा', 'municipality'::public.municipality_type, 20) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-dhangadhimai', 'Siraha', 'Dhangadhimai', 'धनगढीमाई', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-kalyanpur', 'Siraha', 'Kalyanpur', 'कल्याणपुर', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-karjanha', 'Siraha', 'Karjanha', 'कर्जन्हा', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-golbazar', 'Siraha', 'Golbazar', 'गोलबजार', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('siraha-sukhipur', 'Siraha', 'Sukhipur', 'सुखीपुर', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-mithilabihari', 'Dhanusha', 'Mithila Bihari', 'मिथिला बिहारी', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-nagarain', 'Dhanusha', 'Nagarain', 'नगराई', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-ganeshmancharnath', 'Dhanusha', 'Ganeshman Charnath', 'गणेशमान चारनाथ', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-mithila', 'Dhanusha', 'Mithila', 'मिथिला', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-dhanusadham', 'Dhanusha', 'Dhanusadham', 'धनुषाधाम', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-bideha', 'Dhanusha', 'Bideha', 'बिदेहा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-sabaila', 'Dhanusha', 'Sabaila', 'सबाइला', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-kamala', 'Dhanusha', 'Kamala', 'कमला', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-hansapur', 'Dhanusha', 'Hansapur', 'हंसपुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-sahidnagar', 'Dhanusha', 'Sahidnagar', 'सहिदनगर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhanusha-chhireshwarnath', 'Dhanusha', 'Chhireshwarnath', 'क्षिरेश्वरनाथ', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-gaushala', 'Mahottari', 'Gaushala', 'गौशाला', 'municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-ramgopalpur', 'Mahottari', 'Ramgopalpur', 'रामगोपालपुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-aurahi', 'Mahottari', 'Aurahi', 'औरही', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-bardibas', 'Mahottari', 'Bardibas', 'बर्दिवास', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-bhangaha', 'Mahottari', 'Bhangaha', 'भङ्गाहा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-jaleswor', 'Mahottari', 'Jaleswor', 'जलेश्वर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-balwa', 'Mahottari', 'Balwa', 'बलवा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-manrasiswa', 'Mahottari', 'Manra Siswa', 'मनरा सिसवा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-matihani', 'Mahottari', 'Matihani', 'मटिहानी', 'municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mahottari-loharpatti', 'Mahottari', 'Loharpatti', 'लोहारपट्टी', 'municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-barahathawa', 'Sarlahi', 'Barahathawa', 'बराहथवा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-haripur', 'Sarlahi', 'Haripur', 'हरिपुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-ishworpur', 'Sarlahi', 'Ishworpur', 'ईश्वरपुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-lalbandi', 'Sarlahi', 'Lalbandi', 'लालबन्दी', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-malangawa', 'Sarlahi', 'Malangawa', 'मलङ्गवा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-kabilasi', 'Sarlahi', 'Kabilasi', 'कबिलासी', 'municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-bagmati', 'Sarlahi', 'Bagmati', 'बागमती', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-hariwan', 'Sarlahi', 'Hariwan', 'हरिवान', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-balara', 'Sarlahi', 'Balara', 'बलरा', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-haripurwa', 'Sarlahi', 'Haripurwa', 'हरिपुरवा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sarlahi-godaita', 'Sarlahi', 'Godaita', 'गोदैता', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-katahariya', 'Rautahat', 'Katahariya', 'कटहरिया', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-maulapur', 'Rautahat', 'Maulapur', 'मौलापुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-madhavnarayan', 'Rautahat', 'Madhav Narayan', 'माधव नारायण', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-gaur', 'Rautahat', 'Gaur', 'गौर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-gujara', 'Rautahat', 'Gujara', 'गुजरा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-garuda', 'Rautahat', 'Garuda', 'गरुड', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-ishanath', 'Rautahat', 'Ishanath', 'ईशानाथ', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-chandrapur', 'Rautahat', 'Chandrapur', 'चन्द्रपुर', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-dewahigonahi', 'Rautahat', 'Dewahi Gonahi', 'देवाही गोनाही', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-brindaban', 'Rautahat', 'Brindaban', 'वृन्दबन', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-rajpur', 'Rautahat', 'Rajpur', 'राजपुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-rajdevi', 'Rautahat', 'Rajdevi', 'राजदेवी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-gadhimai', 'Rautahat', 'Gadhimai', 'गढीमाई', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-phatuwabijayapur', 'Rautahat', 'Phatuwa Bijayapur', 'विजयपुर फटुवा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-baudhimai', 'Rautahat', 'Baudhimai', 'बौधिमाई', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rautahat-paroha', 'Rautahat', 'Paroha', 'पारोहा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-pacharauta', 'Bara', 'Pacharauta', 'पचरौता', 'municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-nijgadh', 'Bara', 'Nijgadh', 'निजगढ', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-simraungadh', 'Bara', 'Simraungadh', 'सिम्रौनगढ', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-mahagadhimai', 'Bara', 'Mahagadhimai', 'महागढीमाई', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bara-kolhabi', 'Bara', 'Kolhabi', 'कोल्हाबी', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-bahudaramai', 'Parsa', 'Bahudaramai', 'बहुदरमाई', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-pokhariya', 'Parsa', 'Pokhariya', 'पोखरिया', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parsa-parsagadhi', 'Parsa', 'Parsagadhi', 'पर्सागढी', 'municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-jiri', 'Dolakha', 'Jiri', 'जिरी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolakha-bhimeshwor', 'Dolakha', 'Bhimeshwor', 'भीमेश्वर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-chautarasangachokgadhi', 'Sindhupalchok', 'Chautara SangachokGadhi', 'चौतारा साँगाचोकगढी', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-barhabise', 'Sindhupalchok', 'Barhabise', 'बाह्रबिसे', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhupalchok-melamchi', 'Sindhupalchok', 'Melamchi', 'मेलम्ची', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-nilakantha', 'Dhading', 'Nilakantha', 'नीलकण्ठ', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhading-dhunibesi', 'Dhading', 'Dhunibesi', 'धुनिबेसी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-belkotgadhi', 'Nuwakot', 'Belkotgadhi', 'बेलकोटगढी', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nuwakot-bidur', 'Nuwakot', 'Bidur', 'बिदुर', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-kirtipur', 'Kathmandu', 'Kirtipur', 'कीर्तिपुर', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-shankharapur', 'Kathmandu', 'Shankharapur', 'शंखरापुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-nagarjun', 'Kathmandu', 'Nagarjun', 'नागार्जुन', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-kageshworimanahora', 'Kathmandu', 'Kageshwori Manahora', 'कागेश्वरी मनहोरा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-dakshinkali', 'Kathmandu', 'Dakshinkali', 'दक्षिणकाली', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-budhanilakantha', 'Kathmandu', 'Budhanilakantha', 'बुढानिलकण्ठ', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-tarakeshwor', 'Kathmandu', 'Tarakeshwor', 'तारकेश्वर', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-tokha', 'Kathmandu', 'Tokha', 'टोखा', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-chandragiri', 'Kathmandu', 'Chandragiri', 'चन्द्रागिरि', 'municipality'::public.municipality_type, 15) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kathmandu-gokarneshwor', 'Kathmandu', 'Gokarneshwor', 'गोकर्णेश्वर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhaktapur-changunarayan', 'Bhaktapur', 'Changunarayan', 'चाँगुनारायण', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhaktapur-suryabinayak', 'Bhaktapur', 'Suryabinayak', 'सूर्यविनायक', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhaktapur-bhaktapur', 'Bhaktapur', 'Bhaktapur', 'भक्तपुर', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhaktapur-madhyapurthimi', 'Bhaktapur', 'Madhyapur Thimi', 'मध्यपुरथिमि', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lalitpur-mahalaxmi', 'Lalitpur', 'Mahalaxmi', 'महालक्ष्मी', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lalitpur-godawari', 'Lalitpur', 'Godawari', 'गोदावरी', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-banepa', 'Kavrepalanchok', 'Banepa', 'बनेपा', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-mandandeupur', 'Kavrepalanchok', 'Mandandeupur', 'मण्डनदेउपुर', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-dhulikhel', 'Kavrepalanchok', 'Dhulikhel', 'धुलिखेल', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-panauti', 'Kavrepalanchok', 'Panauti', 'पनौती', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-namobuddha', 'Kavrepalanchok', 'Namobuddha', 'नमोबुद्ध', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kavrepalanchok-panchkhal', 'Kavrepalanchok', 'Panchkhal', 'पाँचखाल', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ramechhap-manthali', 'Ramechhap', 'Manthali', 'मन्थली', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ramechhap-ramechhap', 'Ramechhap', 'Ramechhap', 'रामेछाप', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-dudhouli', 'Sindhuli', 'Dudhouli', 'दुधौली', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sindhuli-kamalamai', 'Sindhuli', 'Kamalamai', 'कमलामाई', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('makwanpur-thaha', 'Makwanpur', 'Thaha', 'थाहा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('chitwan-kalika', 'Chitwan', 'Kalika', 'कालिका', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('chitwan-khairahani', 'Chitwan', 'Khairahani', 'खैरहनी', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('chitwan-madi', 'Chitwan', 'Madi', 'माडी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('chitwan-rapti', 'Chitwan', 'Rapti', 'राप्ती', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('chitwan-ratnanagar', 'Chitwan', 'Ratnanagar', 'रत्ननगर', 'municipality'::public.municipality_type, 16) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-palungtar', 'Gorkha', 'Palungtar', 'पालुङटार', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gorkha-gorkha', 'Gorkha', 'Gorkha', 'गोरखा', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('myagdi-beni', 'Myagdi', 'Beni', 'बेनी', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lamjung-sundarbazar', 'Lamjung', 'Sundarbazar', 'सुन्दरबजार', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lamjung-besishahar', 'Lamjung', 'Besishahar', 'बेशिशहर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lamjung-rainas', 'Lamjung', 'Rainas', 'रैनास', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('lamjung-madhyanepal', 'Lamjung', 'MadhyaNepal', 'मध्यनेपाल', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-byas', 'Tanahun', 'Byas', 'ब्यास', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-shuklagandaki', 'Tanahun', 'Shuklagandaki', 'शुक्लागण्डकी', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-bhimad', 'Tanahun', 'Bhimad', 'भीमद', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('tanahun-bhanu', 'Tanahun', 'Bhanu', 'भानु', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasieast-madhyabindu', 'Nawalparasi East', 'Madhyabindu', 'मध्यविन्दु', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;
