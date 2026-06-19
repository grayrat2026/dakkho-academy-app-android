
/// 20 polytechnic departments in Bangladesh.
/// Used by DepartmentPage to render the right info per route.
class DepartmentConfig {
  const DepartmentConfig._();

  static const Map<String, DepartmentInfo> all = {
    'cse': DepartmentInfo(slug: 'cse', name: 'Computer Science & Engineering', nameBn: 'কম্পিউটার সায়েন্স ও ইঞ্জিনিয়ারিং', shortName: 'CSE', color: '#0EA5E9', icon: '💻', description: 'Programming, software engineering, networking, and system design.'),
    'ete': DepartmentInfo(slug: 'ete', name: 'Electronics & Telecommunication Engineering', nameBn: 'ইলেকট্রনিক্স ও টেলিযোগাযোগ ইঞ্জিনিয়ারিং', shortName: 'ETE', color: '#10B981', icon: '📡', description: 'Electronic circuits, communication systems, signal processing.'),
    'eee': DepartmentInfo(slug: 'eee', name: 'Electrical Engineering', nameBn: 'ইলেকট্রিক্যাল ইঞ্জিনিয়ারিং', shortName: 'EEE', color: '#F59E0B', icon: '⚡', description: 'Power systems, electrical machines, power electronics.'),
    'me': DepartmentInfo(slug: 'me', name: 'Mechanical Engineering', nameBn: 'যান্ত্রিক ইঞ্জিনিয়ারিং', shortName: 'ME', color: '#EF4444', icon: '⚙️', description: 'Thermodynamics, machine design, manufacturing processes.'),
    'ce': DepartmentInfo(slug: 'ce', name: 'Civil Engineering', nameBn: 'সিভিল ইঞ্জিনিয়ারিং', shortName: 'CE', color: '#8B5CF6', icon: '🏗️', description: 'Structural engineering, construction, surveying.'),
    'architecture': DepartmentInfo(slug: 'architecture', name: 'Architecture', nameBn: 'আর্কিটেকচার', shortName: 'ARCH', color: '#EC4899', icon: '🏛️', description: 'Building design, urban planning, sustainable architecture.'),
    'textile': DepartmentInfo(slug: 'textile', name: 'Textile Engineering', nameBn: 'টেক্সটাইল ইঞ্জিনিয়ারিং', shortName: 'TEX', color: '#06B6D4', icon: '🧵', description: 'Yarn manufacturing, fabric production, textile chemistry.'),
    'chemical': DepartmentInfo(slug: 'chemical', name: 'Chemical Engineering', nameBn: 'কেমিক্যাল ইঞ্জিনিয়ারিং', shortName: 'CHE', color: '#14B8A6', icon: '⚗️', description: 'Process engineering, petrochemicals, biochemical.'),
    'automobile': DepartmentInfo(slug: 'automobile', name: 'Automobile Engineering', nameBn: 'অটোমোবাইল ইঞ্জিনিয়ারিং', shortName: 'AUTO', color: '#3B82F6', icon: '🚗', description: 'Vehicle design, engine systems, automotive electronics.'),
    'rac': DepartmentInfo(slug: 'rac', name: 'Refrigeration & Air Conditioning', nameBn: 'রেফ্রিজারেশন ও এয়ার কন্ডিশনিং', shortName: 'RAC', color: '#0EA5E9', icon: '❄️', description: 'Cooling systems, HVAC, thermal engineering.'),
    'glass-ceramic': DepartmentInfo(slug: 'glass-ceramic', name: 'Glass & Ceramic Engineering', nameBn: 'কাচ ও সিরামিক ইঞ্জিনিয়ারিং', shortName: 'GCE', color: '#22C55E', icon: '🏺', description: 'Glass manufacturing, ceramic materials, refractories.'),
    'printing': DepartmentInfo(slug: 'printing', name: 'Printing Engineering', nameBn: 'প্রিন্টিং ইঞ্জিনিয়ারিং', shortName: 'PRINT', color: '#A855F7', icon: '🖨️', description: 'Print technology, packaging, graphic design.'),
    'surveying': DepartmentInfo(slug: 'surveying', name: 'Surveying Engineering', nameBn: 'সার্ভেয়িং ইঞ্জিনিয়ারিং', shortName: 'SURV', color: '#F97316', icon: '📐', description: 'Land surveying, GIS, geomatics.'),
    'mechatronics': DepartmentInfo(slug: 'mechatronics', name: 'Mechatronics Engineering', nameBn: 'মেকাট্রনিক্স ইঞ্জিনিয়ারিং', shortName: 'MECHA', color: '#06B6D4', icon: '🤖', description: 'Robotics, automation, control systems.'),
    'mining': DepartmentInfo(slug: 'mining', name: 'Mining Engineering', nameBn: 'মাইনিং ইঞ্জিনিয়ারিং', shortName: 'MIN', color: '#78716C', icon: '⛏️', description: 'Mineral extraction, mine safety, geological engineering.'),
    'metallurgical': DepartmentInfo(slug: 'metallurgical', name: 'Metallurgical Engineering', nameBn: 'মেটালার্জিক্যাল ইঞ্জিনিয়ারিং', shortName: 'MET', color: '#64748B', icon: '🔩', description: 'Metal extraction, material science, alloy development.'),
    'power': DepartmentInfo(slug: 'power', name: 'Power Engineering', nameBn: 'পাওয়ার ইঞ্জিনিয়ারিং', shortName: 'PWR', color: '#EAB308', icon: '🔌', description: 'Power generation, transmission, distribution.'),
    'instrumentation': DepartmentInfo(slug: 'instrumentation', name: 'Instrumentation Engineering', nameBn: 'ইন্সট্রুমেন্টেশন ইঞ্জিনিয়ারিং', shortName: 'INST', color: '#0EA5E9', icon: '📊', description: 'Process control, measurement, automation systems.'),
    'food': DepartmentInfo(slug: 'food', name: 'Food Engineering', nameBn: 'ফুড ইঞ্জিনিয়ারিং', shortName: 'FOOD', color: '#22C55E', icon: '🍞', description: 'Food processing, preservation, quality control.'),
    'leather': DepartmentInfo(slug: 'leather', name: 'Leather Engineering', nameBn: 'লেদার ইঞ্জিনিয়ারিং', shortName: 'LTH', color: '#92400E', icon: '👞', description: 'Leather processing, footwear, leather goods.'),
  };
}

class DepartmentInfo {
  const DepartmentInfo({
    required this.slug,
    required this.name,
    required this.nameBn,
    required this.shortName,
    required this.color,
    required this.icon,
    required this.description,
  });

  final String slug;
  final String name;
  final String nameBn;
  final String shortName;
  final String color;
  final String icon;
  final String description;
}

/// 8 semesters of polytechnic diploma (4-year program).
class SemesterConfig {
  const SemesterConfig._();

  static const Map<int, SemesterInfo> all = {
    1: SemesterInfo(number: 1, name: 'First Semester', nameBn: 'প্রথম সেমিস্টার', period: 'Year 1 · Term 1', subjects: [
      Subject(code: '61011', name: 'English', credits: 3),
      Subject(code: '61012', name: 'Physics', credits: 3),
      Subject(code: '61013', name: 'Mathematics-I', credits: 4),
      Subject(code: '61014', name: 'Chemistry', credits: 3),
      Subject(code: '61015', name: 'Engineering Drawing', credits: 3),
      Subject(code: '61016', name: 'Workshop Practice', credits: 3),
    ]),
    2: SemesterInfo(number: 2, name: 'Second Semester', nameBn: 'দ্বিতীয় সেমিস্টার', period: 'Year 1 · Term 2', subjects: [
      Subject(code: '61021', name: 'English-II', credits: 3),
      Subject(code: '61022', name: 'Mathematics-II', credits: 4),
      Subject(code: '61023', name: 'Physics-II', credits: 3),
      Subject(code: '61024', name: 'Basic Electrical', credits: 3),
      Subject(code: '61025', name: 'Computer Application', credits: 3),
      Subject(code: '61026', name: 'Development of English Skill', credits: 3),
    ]),
    3: SemesterInfo(number: 3, name: 'Third Semester', nameBn: 'তৃতীয় সেমিস্টার', period: 'Year 2 · Term 1', subjects: [
      Subject(code: '61031', name: 'Mathematics-III', credits: 4),
      Subject(code: '61032', name: 'Engineering Mechanics', credits: 3),
      Subject(code: '61033', name: 'Thermodynamics', credits: 3),
      Subject(code: '61034', name: 'Materials Science', credits: 3),
      Subject(code: '61035', name: 'Electrical Circuits', credits: 3),
      Subject(code: '61036', name: 'Electronics-I', credits: 3),
    ]),
    4: SemesterInfo(number: 4, name: 'Fourth Semester', nameBn: 'চতুর্থ সেমিস্টার', period: 'Year 2 · Term 2', subjects: [
      Subject(code: '61041', name: 'Mathematics-IV', credits: 4),
      Subject(code: '61042', name: 'Strength of Materials', credits: 3),
      Subject(code: '61043', name: 'Electronics-II', credits: 3),
      Subject(code: '61044', name: 'Digital Electronics', credits: 3),
      Subject(code: '61045', name: 'Measurement & Instrumentation', credits: 3),
      Subject(code: '61046', name: 'Engineering Economy', credits: 3),
    ]),
    5: SemesterInfo(number: 5, name: 'Fifth Semester', nameBn: 'পঞ্চম সেমিস্টার', period: 'Year 3 · Term 1', subjects: [
      Subject(code: '61051', name: 'Microprocessor & Interfacing', credits: 4),
      Subject(code: '61052', name: 'Data Communication', credits: 3),
      Subject(code: '61053', name: 'Database Management', credits: 3),
      Subject(code: '61054', name: 'Object Oriented Programming', credits: 4),
      Subject(code: '61055', name: 'Operating System', credits: 3),
      Subject(code: '61056', name: 'Industrial Management', credits: 3),
    ]),
    6: SemesterInfo(number: 6, name: 'Sixth Semester', nameBn: 'ষষ্ঠ সেমিস্টার', period: 'Year 3 · Term 2', subjects: [
      Subject(code: '61061', name: 'Computer Networks', credits: 4),
      Subject(code: '61062', name: 'Software Engineering', credits: 3),
      Subject(code: '61063', name: 'Web Engineering', credits: 4),
      Subject(code: '61064', name: 'Computer Architecture', credits: 3),
      Subject(code: '61065', name: 'System Analysis & Design', credits: 3),
      Subject(code: '61066', name: 'Project-I', credits: 3),
    ]),
    7: SemesterInfo(number: 7, name: 'Seventh Semester', nameBn: 'সপ্তম সেমিস্টার', period: 'Year 4 · Term 1', subjects: [
      Subject(code: '61071', name: 'Network Security', credits: 3),
      Subject(code: '61072', name: 'Mobile Application Development', credits: 4),
      Subject(code: '61073', name: 'Cloud Computing', credits: 3),
      Subject(code: '61074', name: 'Artificial Intelligence', credits: 4),
      Subject(code: '61075', name: 'Industrial Training', credits: 4),
      Subject(code: '61076', name: 'Project-II', credits: 4),
    ]),
    8: SemesterInfo(number: 8, name: 'Eighth Semester', nameBn: 'অষ্টম সেমিস্টার', period: 'Year 4 · Term 2', subjects: [
      Subject(code: '61081', name: 'Internet of Things', credits: 4),
      Subject(code: '61082', name: 'Machine Learning', credits: 4),
      Subject(code: '61083', name: 'Cybersecurity', credits: 3),
      Subject(code: '61084', name: 'Blockchain Technology', credits: 3),
      Subject(code: '61085', name: 'Entrepreneurship', credits: 3),
      Subject(code: '61086', name: 'Capstone Project', credits: 6),
    ]),
  };
}

class SemesterInfo {
  const SemesterInfo({
    required this.number,
    required this.name,
    required this.nameBn,
    required this.period,
    required this.subjects,
  });
  final int number;
  final String name;
  final String nameBn;
  final String period;
  final List<Subject> subjects;
}

class Subject {
  const Subject({required this.code, required this.name, required this.credits});
  final String code;
  final String name;
  final int credits;
}
