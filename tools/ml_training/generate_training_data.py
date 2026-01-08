#!/usr/bin/env python3
"""
Medical Chatbot Training Data Generator
Generates comprehensive training data for medical query classification
"""

import json
import random
from typing import List, Dict
import os

class MedicalChatbotDataGenerator:
    def __init__(self):
        self.categories = {
            "cardiac_arrest": 0,
            "choking": 1,
            "bleeding": 2,
            "burns": 3,
            "fracture": 4,
            "poisoning": 5,
            "allergic_reaction": 6,
            "seizure": 7,
            "stroke": 8,
            "diabetic_emergency": 9,
            "breathing_difficulty": 10,
            "heat_exhaustion": 11,
            "hypothermia": 12,
            "head_injury": 13,
            "eye_injury": 14,
            "electric_shock": 15
        }
        
        # Reverse mapping
        self.reverse_categories = {v: k for k, v in self.categories.items()}
        
        # Medical patterns for each category
        self.medical_patterns = self._initialize_medical_patterns()
    
    def _initialize_medical_patterns(self) -> Dict[int, Dict]:
        """Initialize medical patterns for each category"""
        patterns = {
            # 0: Cardiac Arrest
            0: {
                "keywords": [
                    "cardiac arrest", "heart attack", "heart stopped", "no pulse", "unconscious",
                    "not breathing", "chest pain", "heart", "cpr", "resuscitation",
                    "collapsed", "unresponsive", "sudden cardiac arrest", "myocardial infarction",
                    "cardiopulmonary arrest", "dead", "died", "cardiac", "coronary"
                ],
                "patterns": [
                    "What should I do for {symptom}?",
                    "How to help someone with {symptom}?",
                    "Emergency response for {symptom}",
                    "CPR for {symptom}",
                    "What is {symptom}?",
                    "How to perform {symptom}?",
                    "Emergency treatment for {symptom}",
                    "First aid for {symptom}",
                    "Help someone with {symptom}",
                    "What to do if {symptom}?",
                    "Signs of {symptom}",
                    "Symptoms of {symptom}",
                    "How to recognize {symptom}?",
                    "Treatment for {symptom}",
                    "Emergency care for {symptom}",
                    "What happens during {symptom}?",
                    "How to respond to {symptom}?",
                    "Medical emergency {symptom}",
                    "Life saving measures for {symptom}",
                    "What causes {symptom}?"
                ],
                "symptoms": [
                    "chest pain", "heart attack", "no pulse", "unconsciousness", 
                    "cardiac arrest", "heart stopped beating", "sudden collapse",
                    "loss of consciousness", "chest tightness", "arm pain",
                    "jaw pain", "shortness of breath", "sweating", "nausea"
                ]
            },
            
            # 1: Choking
            1: {
                "keywords": [
                    "choking", "airway obstruction", "can't breathe", "suffocation",
                    " Heimlich", "back blows", "abdominal thrusts", "choking victim",
                    "airway", "blocked throat", "swallowed wrong", "gagging",
                    "unable to speak", "high pitched sounds", "grasping throat"
                ],
                "patterns": [
                    "How to help choking victim?",
                    "What to do when someone is choking?",
                    "Emergency treatment for choking",
                    "Choking first aid steps",
                    "Heimlich maneuver instructions",
                    "How to perform abdominal thrusts?",
                    "Signs of choking",
                    "Choking rescue techniques",
                    "What to do if choking?",
                    "Choking prevention",
                    "Adult choking procedure",
                    "Child choking help",
                    "Infant choking response",
                    "Airway obstruction treatment",
                    "Back blow technique",
                    "Choking emergency protocol",
                    "Unconscious choking victim",
                    "Severe choking response",
                    "Choking safety measures",
                    "Recovery position for choking"
                ],
                "symptoms": [
                    "cannot speak", "high pitched sounds", "grasping throat",
                    "inability to breathe", "cyanosis", "panic", "blue lips",
                    "gasping", "wheezing", "coughing", "unable to swallow"
                ]
            },
            
            # 2: Bleeding
            2: {
                "keywords": [
                    "bleeding", "hemorrhage", "cut", "laceration", "wound",
                    "blood loss", "bleeding heavily", "deep cut", "gash",
                    "severe bleeding", "arterial bleeding", "venous bleeding",
                    "external bleeding", "blood spurting", "puncture wound"
                ],
                "patterns": [
                    "How to stop bleeding?",
                    "First aid for bleeding",
                    "Emergency bleeding control",
                    "Severe bleeding treatment",
                    "How to control hemorrhage?",
                    "Bleeding wound care",
                    "What to do for deep cut?",
                    "Heavy bleeding response",
                    "Arterial bleeding help",
                    "Blood loss treatment",
                    "Cut and bleeding care",
                    "Wound bleeding management",
                    "Emergency hemorrhage control",
                    "Severe blood loss",
                    "Bleeding emergency protocol",
                    "Cut wound treatment",
                    "Laceration care",
                    "External bleeding control",
                    "Puncture wound bleeding",
                    "Major bleeding first aid"
                ],
                "symptoms": [
                    "heavy bleeding", "blood spurting", "severe laceration",
                    "deep cuts", "arterial bleeding", "venous bleeding",
                    "blood loss", "pale skin", "weak pulse", "shock",
                    "gushing blood", "continuous bleeding", "profuse bleeding"
                ]
            },
            
            # 3: Burns
            3: {
                "keywords": [
                    "burn", "burns", "thermal burn", "chemical burn", "electrical burn",
                    "scald", "fire burn", "hot liquid", "burn victim", "burn degree",
                    "first degree burn", "second degree burn", "third degree burn",
                    "sunburn", "burn injury", "burn treatment"
                ],
                "patterns": [
                    "How to treat burns?",
                    "First aid for burns",
                    "Emergency burn treatment",
                    "Burn victim care",
                    "What to do for burns?",
                    "Burn degree assessment",
                    "Chemical burn treatment",
                    "Electrical burn response",
                    "Scald burn help",
                    "Fire burn emergency",
                    "Hot liquid burn care",
                    "Burn injury management",
                    "Severe burn treatment",
                    "Minor burn first aid",
                    "Burn emergency protocol",
                    "Thermal burn care",
                    "Sunburn treatment",
                    "Burn blister care",
                    "Burn pain management",
                    "Burn wound dressing"
                ],
                "symptoms": [
                    "red skin", "blisters", "charred skin", "severe pain",
                    "white or black areas", "swelling", "peeling skin",
                    "burning sensation", "skin discoloration", "tissue damage"
                ]
            },
            
            # 4: Fracture
            4: {
                "keywords": [
                    "fracture", "broken bone", "broken", "bone fracture",
                    "compound fracture", "simple fracture", "open fracture",
                    "closed fracture", "dislocation", "sprain", "broken arm",
                    "broken leg", "broken wrist", "broken ankle", "fracture care"
                ],
                "patterns": [
                    "How to treat fracture?",
                    "First aid for broken bone",
                    "Emergency fracture care",
                    "What to do for fracture?",
                    "Broken bone treatment",
                    "Fracture immobilization",
                    "Splinting technique",
                    "Fracture symptoms",
                    "Compound fracture help",
                    "Simple fracture care",
                    "Bone fracture response",
                    "Emergency splinting",
                    "Fracture pain management",
                    "Broken limb care",
                    "Fracture stabilization",
                    "Bone fracture emergency",
                    "Dislocation treatment",
                    "Sprain vs fracture",
                    "Fracture healing process",
                    "Broken bone immobilization"
                ],
                "symptoms": [
                    "severe pain", "deformity", "swelling", "bruising",
                    "inability to move", "grating sound", "visible bone",
                    "numbness", "tingling", "loss of function"
                ]
            },
            
            # 5: Poisoning
            5: {
                "keywords": [
                    "poisoning", "toxin", "toxic", "poison", "ingestion",
                    "poison control", "toxin exposure", "chemical poisoning",
                    "drug overdose", "alcohol poisoning", "carbon monoxide",
                    "food poisoning", "plant poisoning", "medication overdose"
                ],
                "patterns": [
                    "What to do for poisoning?",
                    "Poison control emergency",
                    "First aid for poisoning",
                    "Emergency poisoning treatment",
                    "Chemical poisoning help",
                    "Drug overdose response",
                    "Toxin exposure treatment",
                    "Poison ingestion care",
                    "Carbon monoxide poisoning",
                    "Food poisoning treatment",
                    "Medication overdose help",
                    "Alcohol poisoning care",
                    "Plant poisoning response",
                    "Emergency toxin removal",
                    "Poison control center",
                    "Toxic exposure first aid",
                    "Poison antidote",
                    "Emergency decontamination",
                    "Poisoning symptoms",
                    "Toxic substance exposure"
                ],
                "symptoms": [
                    "nausea", "vomiting", "diarrhea", "dizziness", "confusion",
                    "difficulty breathing", "seizures", "loss of consciousness",
                    "abdominal pain", "headache", "sweating", "weakness"
                ]
            },
            
            # 6: Allergic Reaction
            6: {
                "keywords": [
                    "allergic reaction", "anaphylaxis", "allergy", "severe allergy",
                    "food allergy", "insect sting", "medication allergy",
                    "hives", "swelling", "difficulty breathing", "anaphylactic shock",
                    "epinephrine", "EpiPen", "allergy emergency"
                ],
                "patterns": [
                    "How to treat allergic reaction?",
                    "Emergency anaphylaxis treatment",
                    "First aid for allergy",
                    "Severe allergic reaction help",
                    "What to do for anaphylaxis?",
                    "Allergy emergency response",
                    "Epinephrine administration",
                    "EpiPen usage",
                    "Food allergy reaction",
                    "Insect sting allergy",
                    "Medication allergy help",
                    "Anaphylactic shock treatment",
                    "Allergic reaction symptoms",
                    "Severe allergy response",
                    "Emergency allergy care",
                    "Allergy attack treatment",
                    "Histamine reaction",
                    "Allergy prevention",
                    "Cross contamination allergy",
                    "Emergency allergen removal"
                ],
                "symptoms": [
                    "difficulty breathing", "swelling", "hives", "itching",
                    "wheezing", "throat tightness", "rapid pulse", "low blood pressure",
                    "nausea", "vomiting", "dizziness", "confusion", "loss of consciousness"
                ]
            },
            
            # 7: Seizure
            7: {
                "keywords": [
                    "seizure", "epileptic seizure", "convulsion", "fitting",
                    "epilepsy", "tonic clonic seizure", "absence seizure",
                    "partial seizure", "seizure disorder", "seizure first aid",
                    "protect during seizure", "postictal phase"
                ],
                "patterns": [
                    "How to help during seizure?",
                    "First aid for seizure",
                    "Emergency seizure treatment",
                    "What to do for seizure?",
                    "Seizure victim care",
                    "Convulsion response",
                    "Epileptic seizure help",
                    "Seizure emergency protocol",
                    "Protecting seizure victim",
                    "Seizure duration management",
                    "Post seizure care",
                    "Seizure recovery position",
                    "Tonic clonic seizure help",
                    "Absence seizure recognition",
                    "Seizure safety measures",
                    "Emergency seizure control",
                    "Seizure first response",
                    "Convulsive episode care",
                    "Seizure injury prevention",
                    "Seizure medication emergency"
                ],
                "symptoms": [
                    "convulsions", "loss of consciousness", "stiffening",
                    "twitching", "confusion", "drooling", "incontinence",
                    "postictal confusion", "aura", "staring", "jerking movements"
                ]
            },
            
            # 8: Stroke
            8: {
                "keywords": [
                    "stroke", "brain attack", "cerebrovascular accident", "CVA",
                    "ischemic stroke", "hemorrhagic stroke", "mini stroke",
                    "TIA", "transient ischemic attack", "stroke symptoms",
                    "FAST", "face drooping", "arm weakness", "speech difficulty"
                ],
                "patterns": [
                    "How to recognize stroke?",
                    "Stroke emergency response",
                    "First aid for stroke",
                    "What to do for stroke?",
                    "Stroke symptoms recognition",
                    "FAST test for stroke",
                    "Brain attack treatment",
                    "Cerebrovascular emergency",
                    "Mini stroke response",
                    "TIA treatment",
                    "Ischemic stroke help",
                    "Hemorrhagic stroke care",
                    "Stroke victim positioning",
                    "Emergency stroke care",
                    "Stroke warning signs",
                    "Time critical stroke",
                    "Stroke assessment",
                    "Brain injury stroke",
                    "Stroke rehabilitation",
                    "Stroke prevention emergency"
                ],
                "symptoms": [
                    "face drooping", "arm weakness", "speech difficulty",
                    "sudden numbness", "confusion", "trouble speaking",
                    "trouble understanding", "vision problems", "severe headache",
                    "loss of balance", "difficulty walking", "coordination problems"
                ]
            },
            
            # 9: Diabetic Emergency
            9: {
                "keywords": [
                    "diabetic emergency", "diabetes", "hypoglycemia", "hyperglycemia",
                    "low blood sugar", "high blood sugar", "diabetic coma",
                    "insulin shock", "diabetic ketoacidosis", "DKA",
                    "blood sugar emergency", "diabetic crisis"
                ],
                "patterns": [
                    "How to treat diabetic emergency?",
                    "First aid for diabetes",
                    "Emergency diabetes treatment",
                    "What to do for diabetic emergency?",
                    "Hypoglycemia response",
                    "Hyperglycemia treatment",
                    "Low blood sugar help",
                    "High blood sugar emergency",
                    "Diabetic coma care",
                    "Insulin shock treatment",
                    "Blood sugar monitoring",
                    "Diabetic crisis response",
                    "Emergency glucose administration",
                    "Diabetes medication overdose",
                    "Diabetic ketoacidosis help",
                    "Blood glucose emergency",
                    "Diabetic shock treatment",
                    "Sugar level emergency",
                    "Diabetic medication error",
                    "Emergency diabetes management"
                ],
                "symptoms": [
                    "confusion", "dizziness", "sweating", "shaking", "nausea",
                    "rapid heartbeat", "headache", "blurred vision", "extreme thirst",
                    "frequent urination", "fruity breath", "breathing difficulty", "coma"
                ]
            },
            
            # 10: Breathing Difficulty
            10: {
                "keywords": [
                    "breathing difficulty", "shortness of breath", "dyspnea",
                    "asthma attack", "respiratory distress", "can't breathe",
                    "choking", "gasping", "wheezing", "respiratory emergency",
                    "lung emergency", "airway obstruction", "breathing problems"
                ],
                "patterns": [
                    "How to help breathing difficulty?",
                    "First aid for breathing problems",
                    "Emergency respiratory treatment",
                    "What to do for breathing difficulty?",
                    "Asthma attack help",
                    "Respiratory distress response",
                    "Shortness of breath treatment",
                    "Breathing emergency care",
                    "Gasping patient help",
                    "Wheezing treatment",
                    "Airway obstruction breathing",
                    "Respiratory failure emergency",
                    "Lung breathing problems",
                    "Dyspnea management",
                    "Breathing assistance",
                    "Emergency oxygen therapy",
                    "Respiratory support",
                    "Breathing apparatus help",
                    "Ventilation emergency",
                    "Respiratory arrest response"
                ],
                "symptoms": [
                    "gasping", "wheezing", "rapid breathing", "shallow breathing",
                    "blue lips", "difficulty speaking", "panicked breathing",
                    "chest tightness", "cyanosis", "grunting", "nasal flaring"
                ]
            },
            
            # 11: Heat Exhaustion
            11: {
                "keywords": [
                    "heat exhaustion", "heat stroke", "hyperthermia",
                    "overheating", "heat illness", "heat stress",
                    "dehydration", "heat cramps", "sun exposure",
                    "hot weather emergency", "heat wave"
                ],
                "patterns": [
                    "How to treat heat exhaustion?",
                    "First aid for heat illness",
                    "Emergency heat treatment",
                    "What to do for heat exhaustion?",
                    "Heat stroke response",
                    "Overheating emergency care",
                    "Heat stress treatment",
                    "Dehydration emergency",
                    "Heat cramps help",
                    "Sun exposure emergency",
                    "Hot weather emergency",
                    "Heat wave safety",
                    "Hyperthermia treatment",
                    "Body temperature emergency",
                    "Cooling measures heat",
                    "Heat illness prevention",
                    "Emergency fluid replacement",
                    "Heat exhaustion symptoms",
                    "Heat related emergency",
                    "Sun stroke treatment"
                ],
                "symptoms": [
                    "heavy sweating", "weakness", "dizziness", "nausea",
                    "headache", "rapid pulse", "muscle cramps", "confusion",
                    "dark urine", "thirst", "fatigue", "fainting"
                ]
            },
            
            # 12: Hypothermia
            12: {
                "keywords": [
                    "hypothermia", "cold emergency", "overcooling",
                    "low body temperature", "frostbite", "freezing",
                    "cold exposure", "frozen", "shivering", "cold weather emergency"
                ],
                "patterns": [
                    "How to treat hypothermia?",
                    "First aid for hypothermia",
                    "Emergency cold treatment",
                    "What to do for hypothermia?",
                    "Cold exposure emergency",
                    "Low body temperature help",
                    "Overcooling treatment",
                    "Freezing emergency care",
                    "Cold weather emergency",
                    "Frostbite treatment",
                    "Shivering emergency",
                    "Body temperature emergency",
                    "Cold injury treatment",
                    "Hypothermia prevention",
                    "Emergency warming",
                    "Cold shock treatment",
                    "Frostbite emergency",
                    "Cold immersion emergency",
                    "Extreme cold response",
                    "Winter emergency care"
                ],
                "symptoms": [
                    "shivering", "confusion", "slurred speech", "fatigue",
                    "clumsiness", "drowsiness", "memory loss", "pale skin",
                    "cold skin", "slow breathing", "weak pulse", "stiff muscles"
                ]
            },
            
            # 13: Head Injury
            13: {
                "keywords": [
                    "head injury", "head trauma", "concussion", "brain injury",
                    "head wound", "skull fracture", "head impact",
                    "head blow", "cranial injury", "traumatic brain injury",
                    "TBI", "head contusion", "head laceration"
                ],
                "patterns": [
                    "How to treat head injury?",
                    "First aid for head trauma",
                    "Emergency head injury treatment",
                    "What to do for head injury?",
                    "Concussion response",
                    "Brain injury emergency",
                    "Head wound care",
                    "Skull fracture help",
                    "Head impact treatment",
                    "Traumatic brain injury care",
                    "Head injury assessment",
                    "Concussion symptoms",
                    "Head injury monitoring",
                    "Brain injury prevention",
                    "Head trauma emergency",
                    "Cranial injury treatment",
                    "Head contusion care",
                    "Emergency head stabilization",
                    "Head injury complications",
                    "Brain damage prevention"
                ],
                "symptoms": [
                    "headache", "confusion", "dizziness", "nausea", "vomiting",
                    "loss of consciousness", "memory problems", "slurred speech",
                    "weakness", "seizures", "pupil changes", "neck pain"
                ]
            },
            
            # 14: Eye Injury
            14: {
                "keywords": [
                    "eye injury", "eye trauma", "eye emergency", "eye wound",
                    "eye damage", "eye irritation", "chemical eye burn",
                    "eye puncture", "foreign object in eye", "eye bleeding",
                    "eye pain", "vision loss", "eye surgery emergency"
                ],
                "patterns": [
                    "How to treat eye injury?",
                    "First aid for eye trauma",
                    "Emergency eye injury treatment",
                    "What to do for eye injury?",
                    "Eye wound care",
                    "Chemical eye burn treatment",
                    "Foreign object in eye",
                    "Eye puncture emergency",
                    "Eye bleeding treatment",
                    "Eye pain management",
                    "Vision emergency",
                    "Eye emergency protocol",
                    "Eye protection emergency",
                    "Eye trauma response",
                    "Eye injury assessment",
                    "Chemical eye exposure",
                    "Eye damage prevention",
                    "Emergency eye irrigation",
                    "Eye safety emergency",
                    "Ocular injury treatment"
                ],
                "symptoms": [
                    "eye pain", "vision changes", "light sensitivity", "bleeding",
                    "swelling", "redness", "discharge", "double vision",
                    "loss of vision", "eye irritation", "foreign body sensation"
                ]
            },
            
            # 15: Electric Shock
            15: {
                "keywords": [
                    "electric shock", "electrocution", "electrical injury",
                    "high voltage", "low voltage", "electrical burn",
                    "lightning strike", "electrical current", "electrical emergency",
                    "shock from electricity", "electrical accident"
                ],
                "patterns": [
                    "How to treat electric shock?",
                    "First aid for electrocution",
                    "Emergency electric shock treatment",
                    "What to do for electric shock?",
                    "Electrocution response",
                    "Electrical injury emergency",
                    "High voltage shock help",
                    "Low voltage shock treatment",
                    "Electrical burn care",
                    "Lightning strike emergency",
                    "Electrical current injury",
                    "Electrical accident response",
                    "Electric shock first aid",
                    "Electrical emergency protocol",
                    "Shock from electricity help",
                    "Electrical burn treatment",
                    "Electric injury care",
                    "Power line shock emergency",
                    "Electrical contact injury",
                    "Current flow injury"
                ],
                "symptoms": [
                    "burn marks", "muscle contractions", "irregular heartbeat",
                    "breathing difficulty", "loss of consciousness", "muscle pain",
                    "numbness", "tingling", "weakness", "seizures", "cardiac arrest"
                ]
            }
        }
        
        return patterns

    def generate_training_data(self, samples_per_category: int = 200) -> List[Dict]:
        """Generate comprehensive training data"""
        training_data = []
        
        print(f"Generating {samples_per_category} samples per category...")
        
        for category_id, category_info in self.medical_patterns.items():
            category_name = self.reverse_categories[category_id]
            
            for i in range(samples_per_category):
                # Randomly select generation method
                method = random.choice(['pattern', 'keyword', 'variation'])
                
                if method == 'pattern':
                    # Use pattern-based generation
                    pattern = random.choice(category_info['patterns'])
                    if '{symptom}' in pattern:
                        symptom = random.choice(category_info['symptoms'])
                        text = pattern.format(symptom=symptom)
                    else:
                        # Simple pattern without substitution
                        keyword = random.choice(category_info['keywords'])
                        text = f"{pattern} {keyword}"
                        
                elif method == 'keyword':
                    # Keyword-based generation
                    keyword = random.choice(category_info['keywords'])
                    text = f"How to treat {keyword}?"
                    
                else:  # variation
                    # Medical variation generation
                    variations = [
                        f"What should I do if someone has {category_name.replace('_', ' ')}?",
                        f"Emergency response for {category_name.replace('_', ' ')}",
                        f"First aid for {category_name.replace('_', ' ')}",
                        f"Medical help for {category_name.replace('_', ' ')}",
                        f"Emergency care when someone has {category_name.replace('_', ' ')}"
                    ]
                    text = random.choice(variations)
                
                # Clean and normalize text
                text = self._normalize_text(text)
                
                training_data.append({
                    'text': text,
                    'label': category_id,
                    'category': category_name
                })
        
        # Add some general medical queries
        general_queries = [
            "What is first aid?",
            "Emergency medical help",
            "Medical emergency response",
            "Basic life support",
            "Emergency procedures",
            "Medical emergency",
            "First aid basics",
            "Emergency medical care",
            "Medical emergency kit",
            "Emergency response training"
        ]
        
        # Assign these to a general emergency category (using cardiac arrest as default)
        for query in general_queries:
            training_data.append({
                'text': self._normalize_text(query),
                'label': 0,  # Default to cardiac arrest
                'category': 'general_emergency'
            })
        
        print(f"Generated {len(training_data)} training samples")
        return training_data

    def _normalize_text(self, text: str) -> str:
        """Clean and normalize text"""
        # Remove extra spaces
        text = ' '.join(text.split())
        # Convert to lowercase for consistency
        text = text.lower()
        # Remove trailing punctuation
        text = text.strip('.,!?')
        return text

    def save_training_data(self, training_data: List[Dict], output_path: str):
        """Save training data to JSON file"""
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(training_data, f, indent=2, ensure_ascii=False)
        
        print(f"Training data saved to: {output_path}")
        print(f"Total samples: {len(training_data)}")
        
        # Print distribution
        label_counts = {}
        for item in training_data:
            label = item['label']
            if label not in label_counts:
                label_counts[label] = 0
            label_counts[label] += 1
        
        print("\nLabel distribution:")
        for label_id, count in sorted(label_counts.items()):
            category_name = self.reverse_categories.get(label_id, f"Unknown_{label_id}")
            print(f"  {category_name}: {count} samples")

    def create_vocabulary(self, training_data: List[Dict]) -> Dict[str, int]:
        """Create vocabulary from training data"""
        vocab = {'<PAD>': 0, '<UNK>': 1, '<START>': 2, '<END>': 3}
        vocab_size = 4
        
        for item in training_data:
            words = item['text'].split()
            for word in words:
                if word not in vocab:
                    vocab[word] = vocab_size
                    vocab_size += 1
        
        return vocab

    def save_vocabulary(self, vocab: Dict[str, int], output_path: str):
        """Save vocabulary to JSON file"""
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(vocab, f, indent=2, ensure_ascii=False)
        
        print(f"Vocabulary saved to: {output_path}")
        print(f"Vocabulary size: {len(vocab)}")

def main():
    """Main function to generate training data"""
    generator = MedicalChatbotDataGenerator()
    
    # Configuration
    samples_per_category = 200  # Adjust based on your needs
    output_dir = "data"
    
    # Generate training data
    training_data = generator.generate_training_data(samples_per_category)
    
    # Save training data
    training_output = os.path.join(output_dir, "medical_training_data.json")
    generator.save_training_data(training_data, training_output)
    
    # Create and save vocabulary
    vocab = generator.create_vocabulary(training_data)
    vocab_output = os.path.join(output_dir, "vocabulary.json")
    generator.save_vocabulary(vocab, vocab_output)
    
    print(f"\nTraining data generation complete!")
    print(f"Training data: {training_output}")
    print(f"Vocabulary: {vocab_output}")
    print(f"Ready for model training with {len(training_data)} samples")

if __name__ == "__main__":
    main()