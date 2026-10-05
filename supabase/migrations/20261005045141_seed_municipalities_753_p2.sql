-- HYA-253 (3/4) seed part 2 of 4: municipalities rows 190-378 of 753
-- Idempotent upserts on slug; FK and assertions live in part 4.

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasieast-devchuli', 'Nawalparasi East', 'Devchuli', 'देवचुली', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasieast-gaidakot', 'Nawalparasi East', 'Gaidakot', 'गैडाकोट', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasieast-kawasoti', 'Nawalparasi East', 'Kawasoti', 'कावासोती', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-putalibazar', 'Syangja', 'Putalibazar', 'पुतलीबजार', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-bhirkot', 'Syangja', 'Bhirkot', 'भिरकोट', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-galyang', 'Syangja', 'Galyang', 'गल्याङ', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-chapakot', 'Syangja', 'Chapakot', 'चापाकोट', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('syangja-waling', 'Syangja', 'Waling', 'वालिङ', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parbat-kushma', 'Parbat', 'Kushma', 'कुश्मा', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('parbat-phalebas', 'Parbat', 'Phalebas', 'फलेबास', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-jaimuni', 'Baglung', 'Jaimuni', 'जैमुनी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-baglung', 'Baglung', 'Baglung', 'बाग्लुङ', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-galkot', 'Baglung', 'Galkot', 'गलकोट', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baglung-dhorpatan', 'Baglung', 'Dhorpatan', 'ढोरपाटन', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rolpa-rolpa', 'Rolpa', 'Rolpa', 'रोल्पा', 'municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-pyuthan', 'Pyuthan', 'Pyuthan', 'प्युठान', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('pyuthan-sworgadwary', 'Pyuthan', 'Sworgadwary', 'स्वर्गद्वारी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-resunga', 'Gulmi', 'Resunga', 'रेसुंगा', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('gulmi-musikot', 'Gulmi', 'Musikot', 'मुसिकोट', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('arghakhanchi-bhumekasthan', 'Arghakhanchi', 'Bhumekasthan', 'भुमेकस्थान', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('arghakhanchi-sitganga', 'Arghakhanchi', 'Sitganga', 'सितगंगा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('arghakhanchi-sandhikharka', 'Arghakhanchi', 'Sandhikharka', 'सन्धिखर्क', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-tansen', 'Palpa', 'Tansen', 'तानसेन', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('palpa-rampur', 'Palpa', 'Rampur', 'रामपुर', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasiwest-bardaghat', 'Nawalparasi West', 'Bardaghat', 'बर्दघाट', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasiwest-sunwal', 'Nawalparasi West', 'Sunwal', 'सुनवल', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('nawalparasiwest-ramgram', 'Nawalparasi West', 'Ramgram', 'रामग्राम', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-lumbinisanskritik', 'Rupandehi', 'Lumbini Sanskritik', 'लुम्बिनी संस्कृत', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-devdaha', 'Rupandehi', 'Devdaha', 'देवदह', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-sainamaina', 'Rupandehi', 'Sainamaina', 'सैनामैना', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-siddharthanagar', 'Rupandehi', 'Siddharthanagar', 'सिद्धार्थनगर', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rupandehi-tillotama', 'Rupandehi', 'Tillotama', 'तिलोतमा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-shivaraj', 'Kapilvastu', 'Shivaraj', 'शिवराज', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-kapilbastu', 'Kapilvastu', 'Kapilbastu', 'कपिलवस्तु', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-buddhabhumi', 'Kapilvastu', 'Buddhabhumi', 'बुद्धभूमि', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-maharajgunj', 'Kapilvastu', 'Maharajgunj', 'महाराजगन्ज', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-banganga', 'Kapilvastu', 'Banganga', 'बाणगंगा', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kapilvastu-krishnanagar', 'Kapilvastu', 'Krishnanagar', 'कृष्णनगर', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dang-lamahi', 'Dang', 'Lamahi', 'लमही', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('banke-kohalpur', 'Banke', 'Kohalpur', 'कोहलपुर', 'municipality'::public.municipality_type, 15) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bardiya-thakurbaba', 'Bardiya', 'Thakurbaba', 'ठाकुरबाबा', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bardiya-bansagadhi', 'Bardiya', 'Bansagadhi', 'बाँसगढी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bardiya-barbardiya', 'Bardiya', 'Barbardiya', 'बारबर्दिया', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bardiya-rajapur', 'Bardiya', 'Rajapur', 'राजापुर', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bardiya-madhuwan', 'Bardiya', 'Madhuwan', 'मधुवन', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bardiya-gulariya', 'Bardiya', 'Gulariya', 'गुलरिया', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolpa-tripurasundari', 'Dolpa', 'Tripurasundari', 'त्रिपुरासुन्दरी', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dolpa-thulibheri', 'Dolpa', 'Thuli Bheri', 'ठुली भेरी', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('mugu-chhayanathrara', 'Mugu', 'Chhayanath Rara', 'छायानाथ रारा', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jumla-chandannath', 'Jumla', 'Chandannath', 'चन्दननाथ', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-khandachakra', 'Kalikot', 'Khandachakra', 'खंडचक्र', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-raskot', 'Kalikot', 'Raskot', 'रास्कोट', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kalikot-tilagufa', 'Kalikot', 'Tilagufa', 'तिलागुफा', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-aathabis', 'Dailekh', 'Aathabis', 'आठबिस', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-dullu', 'Dailekh', 'Dullu', 'दुल्लु', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-chamundabindrasaini', 'Dailekh', 'Chamunda Bindrasaini', 'चामुण्डा बिन्द्रसैनी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dailekh-narayan', 'Dailekh', 'Narayan', 'नारायण', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jajarkot-nalagad', 'Jajarkot', 'Nalagad', 'नालागड', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jajarkot-bheri', 'Jajarkot', 'Bheri', 'भेरी', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jajarkot-chhedagad', 'Jajarkot', 'Chhedagad', 'छेडागढ', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumwest-aathbiskot', 'Rukum West', 'Aathbiskot', 'आठबिस्कोट', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumwest-chaurjahari', 'Rukum West', 'Chaurjahari', 'चौरजहारी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('rukumwest-musikot', 'Rukum West', 'Musikot', 'मुसिकोट', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-sharada', 'Salyan', 'Sharada', 'शारदा', 'municipality'::public.municipality_type, 15) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-bangad', 'Salyan', 'Bangad', 'बांगड', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('salyan-bagchaur', 'Salyan', 'Bagchaur', 'बागचौर', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-gurbhakot', 'Surkhet', 'Gurbhakot', 'गुर्भाकोट', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-panchpuri', 'Surkhet', 'Panchpuri', 'पञ्चपुरी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-bheriganga', 'Surkhet', 'Bheriganga', 'भेरीगंगा', 'municipality'::public.municipality_type, 13) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-lekbeshi', 'Surkhet', 'Lekbeshi', 'लेकबेशी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('surkhet-birendranagar', 'Surkhet', 'Birendranagar', 'वीरेन्द्रनगर', 'municipality'::public.municipality_type, 16) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-badimalika', 'Bajura', 'Badimalika', 'बडिमालिका', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-tribeni', 'Bajura', 'Tribeni', 'त्रिवेणी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-budhiganga', 'Bajura', 'Budhiganga', 'बुढीगंगा', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajura-budhinanda', 'Bajura', 'Budhinanda', 'बुढीनन्द', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-jayaprithivi', 'Bajhang', 'JayaPrithivi', 'जय पृथ्वी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bajhang-bungal', 'Bajhang', 'Bungal', 'बुंगल', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-mahakali', 'Darchula', 'Mahakali', 'महाकाली', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('darchula-shailyashikhar', 'Darchula', 'Shailyashikhar', 'शैल्यशिखर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-melauli', 'Baitadi', 'Melauli', 'मेलौली', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-dasharathchanda', 'Baitadi', 'Dasharathchanda', 'दशरथचन्द', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-purchaudi', 'Baitadi', 'Purchaudi', 'पुर्चौडी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('baitadi-patan', 'Baitadi', 'Patan', 'पाटन', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dadeldhura-amargadhi', 'Dadeldhura', 'Amargadhi', 'अमरगढी', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dadeldhura-parashuram', 'Dadeldhura', 'Parashuram', 'परशुराम', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-dipayalsilgadi', 'Doti', 'Dipayal Silgadi', 'दिपायल सिलगढी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('doti-shikhar', 'Doti', 'Shikhar', 'शिखर', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-sanphebagar', 'Achham', 'Sanphebagar', 'साँफेबगर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-mangalsen', 'Achham', 'Mangalsen', 'मंगलसेन', 'municipality'::public.municipality_type, 14) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-kamalbazar', 'Achham', 'Kamalbazar', 'कमलबजार', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('achham-panchadewalbinayak', 'Achham', 'Panchadewal Binayak', 'पञ्चदेवल विनायक', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-tikapur', 'Kailali', 'Tikapur', 'टीकापुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-ghodaghodi', 'Kailali', 'Ghodaghodi', 'घोडाघोडी', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-bhajani', 'Kailali', 'Bhajani', 'भजनी', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-gauriganga', 'Kailali', 'Gauriganga', 'गौरीगंगा', 'municipality'::public.municipality_type, 11) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-godawari', 'Kailali', 'Godawari', 'गोदावरी', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kailali-lamkichuha', 'Kailali', 'Lamkichuha', 'लम्कीचुहा', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-punarbas', 'Kanchanpur', 'Punarbas', 'पुनर्वास', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-krishnapur', 'Kanchanpur', 'Krishnapur', 'कृष्णपुर', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-mahakali', 'Kanchanpur', 'Mahakali', 'महाकाली', 'municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-bedkot', 'Kanchanpur', 'Bedkot', 'बेदकोट', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-belauri', 'Kanchanpur', 'Belauri', 'बेलौरी', 'municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-bhimdatta', 'Kanchanpur', 'Bhimdatta', 'भीमदत्त', 'municipality'::public.municipality_type, 19) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('kanchanpur-shuklaphanta', 'Kanchanpur', 'Shuklaphanta', 'शुक्लाफाँटा', 'municipality'::public.municipality_type, 12) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-sidingba', 'Taplejung', 'Sidingba', 'सिडिङबा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-meringden', 'Taplejung', 'Meringden', 'Meringden', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-maiwakhola', 'Taplejung', 'Maiwakhola', 'माइवाखोला', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-phaktanglung', 'Taplejung', 'Phaktanglung', 'फाक्ताङलुङ', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-sirijangha', 'Taplejung', 'Sirijangha', 'सिरिजाङ्घा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-mikwakhola', 'Taplejung', 'Mikwakhola', 'मिक्वाखोला', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-aathraitribeni', 'Taplejung', 'Aathrai Tribeni', 'आठराई त्रिवेणी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('taplejung-pathivarayangwarak', 'Taplejung', 'Pathivara Yangwarak', 'पाथिवरा यांगवारक', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-makalu', 'Sankhuwasabha', 'Makalu', 'मकालु', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-chichila', 'Sankhuwasabha', 'Chichila', 'चिचिला', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-silichong', 'Sankhuwasabha', 'Silichong', 'सिलिचङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-bhotkhola', 'Sankhuwasabha', 'Bhotkhola', 'भोटखोला', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sankhuwasabha-sabhapokhari', 'Sankhuwasabha', 'Sabhapokhari', 'सभापोखरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('solukhumbu-sotang', 'Solukhumbu', 'Sotang', 'सोटाङ', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('solukhumbu-mahakulung', 'Solukhumbu', 'Mahakulung', 'महाकुलुङ', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('solukhumbu-likhupike', 'Solukhumbu', 'Likhupike', 'लिखुपिके', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('solukhumbu-nechasalyan', 'Solukhumbu', 'Nechasalyan', 'नेचासल्यान', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('solukhumbu-thulungdudhkoshi', 'Solukhumbu', 'Thulung Dudhkoshi', 'थुलुङ दुधकोशी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('solukhumbu-maapyadudhkoshi', 'Solukhumbu', 'Maapya Dudhkoshi', 'माप्या दुधकोशी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('solukhumbu-khumbupasanglahmu', 'Solukhumbu', 'Khumbupasanglahmu', 'खुम्बुपसङ्लाहमु', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('okhaldhunga-likhu', 'Okhaldhunga', 'Likhu', 'लिखु', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('okhaldhunga-molung', 'Okhaldhunga', 'Molung', 'मोलुङ', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('okhaldhunga-sunkoshi', 'Okhaldhunga', 'Sunkoshi', 'सुनकोशी', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('okhaldhunga-champadevi', 'Okhaldhunga', 'Champadevi', 'चम्पादेवी', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('okhaldhunga-chisankhugadhi', 'Okhaldhunga', 'Chisankhugadhi', 'चिसंखुगढी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('okhaldhunga-khijidemba', 'Okhaldhunga', 'Khijidemba', 'खिजिदेम्बा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('okhaldhunga-manebhanjyang', 'Okhaldhunga', 'Manebhanjyang', 'मानेभञ्ज्याङ', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-sakela', 'Khotang', 'Sakela', 'साकेला', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-khotehang', 'Khotang', 'Khotehang', 'खोटेहाङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-barahapokhari', 'Khotang', 'Barahapokhari', 'बराहापोखरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-ainselukhark', 'Khotang', 'Ainselukhark', 'ऐसेलुखर्क', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-rawabesi', 'Khotang', 'Rawa Besi', 'रवा बेसी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-kepilasagadhi', 'Khotang', 'Kepilasagadhi', 'केपिलासगढी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-jantedhunga', 'Khotang', 'Jantedhunga', 'जानतेढुङ्गा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('khotang-diprung', 'Khotang', 'Diprung', 'डिप्रुङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-arun', 'Bhojpur', 'Arun', 'अरुण', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-aamchowk', 'Bhojpur', 'Aamchowk', 'आमचोक', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-hatuwagadhi', 'Bhojpur', 'Hatuwagadhi', 'हतुवागढी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-pauwadungma', 'Bhojpur', 'Pauwadungma', 'पौवाडुङ्मा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-temkemaiyung', 'Bhojpur', 'Temkemaiyung', 'टेम्केमाइयुङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-salpasilichho', 'Bhojpur', 'Salpasilichho', 'सालपसिलिछो', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('bhojpur-ramprasad', 'Bhojpur', 'Ramprasad', 'रामप्रसाद', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhankuta-chaubise', 'Dhankuta', 'Chaubise', 'चौबिसे', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhankuta-shahidbhumi', 'Dhankuta', 'Shahidbhumi', 'शहिदभूमि', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhankuta-sangurigadhi', 'Dhankuta', 'Sangurigadhi', 'साँगुरीगढी', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('dhankuta-chhatharjorpati', 'Dhankuta', 'Chhathar Jorpati', 'छथर जोरपाटी', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('terhathum-chhathar', 'Terhathum', 'Chhathar', 'छथर', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('terhathum-phedap', 'Terhathum', 'Phedap', 'फेडाप', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('terhathum-aathrai', 'Terhathum', 'Aathrai', 'आठराई', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('terhathum-menchayam', 'Terhathum', 'Menchayam', 'मेन्चायम', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('panchthar-yangwarak', 'Panchthar', 'Yangwarak', 'याङ्गवारक', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('panchthar-hilihang', 'Panchthar', 'Hilihang', 'हिलिहाङ', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('panchthar-falelung', 'Panchthar', 'Falelung', 'फालेलुङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('panchthar-tumbewa', 'Panchthar', 'Tumbewa', 'तुम्बेवा', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('panchthar-kummayak', 'Panchthar', 'Kummayak', 'कुमायक', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('panchthar-miklajung', 'Panchthar', 'Miklajung', 'मिक्लाजुङ', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('panchthar-falgunanda', 'Panchthar', 'Falgunanda', 'फाल्गुनन्द', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-rong', 'Ilam', 'Rong', 'रोङ', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-mangsebung', 'Ilam', 'Mangsebung', 'मङ्गेबुङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-chulachuli', 'Ilam', 'Chulachuli', 'चुलाचुली', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-sandakpur', 'Ilam', 'Sandakpur', 'सन्दकपुर', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-fakphokthum', 'Ilam', 'Fakphokthum', 'फाकफोक्थुम', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('ilam-maijogmai', 'Ilam', 'Maijogmai', 'माइजोगमाई', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-kamal', 'Jhapa', 'Kamal', 'कमल', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-jhapa', 'Jhapa', 'Jhapa', 'झापा', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-kachankawal', 'Jhapa', 'Kachankawal', 'कचनकवल', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-gauriganj', 'Jhapa', 'Gauriganj', 'गौरीगञ्ज', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-barhadashi', 'Jhapa', 'Barhadashi', 'बाह्रदशी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-haldibari', 'Jhapa', 'Haldibari', 'हल्दिबारी', 'rural_municipality'::public.municipality_type, 5) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('jhapa-buddhashanti', 'Jhapa', 'Buddhashanti', 'बुद्धशान्ति', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-jahada', 'Morang', 'Jahada', 'जहादा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-katahari', 'Morang', 'Katahari', 'कटहरी', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-gramthan', 'Morang', 'Gramthan', 'ग्रामथान', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-dhanpalthan', 'Morang', 'Dhanpalthan', 'धनपालथान', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-kerabari', 'Morang', 'Kerabari', 'केराबारी', 'rural_municipality'::public.municipality_type, 10) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-budhiganga', 'Morang', 'Budhiganga', 'बुढीगंगा', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-kanepokhari', 'Morang', 'Kanepokhari', 'कानेपोखरी', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('morang-miklajung', 'Morang', 'Miklajung', 'मिक्लाजुङ', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-gadhi', 'Sunsari', 'Gadhi', 'गढी', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-koshi', 'Sunsari', 'Koshi', 'कोशी', 'rural_municipality'::public.municipality_type, 8) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-barju', 'Sunsari', 'Barju', 'बर्जु', 'rural_municipality'::public.municipality_type, 6) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-harinagar', 'Sunsari', 'Harinagar', 'हरिनगर', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-dewanganj', 'Sunsari', 'Dewanganj', 'देवानगन्ज', 'rural_municipality'::public.municipality_type, 7) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('sunsari-bhokrahanarsing', 'Sunsari', 'Bhokraha Narsing', 'भोक्राहा नरसिङ्ग', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;

insert into public.municipalities (slug, district, name, name_ne, type, ward_count) values
  ('udayapur-tapli', 'Udayapur', 'Tapli', 'तापली', 'rural_municipality'::public.municipality_type, 9) on conflict (slug) do nothing;
