#!/usr/bin/env python3
"""
Medical Chatbot Training Dataset Generator
Creates a comprehensive dataset for training a medical chatbot classifier
"""

import json
import random
from typing import List, Dict, Tuple

class MedicalChatbotDatasetGenerator:
    def __init__(self):
        self.categories = {
            'emergency_cpr': 0,
            'bleeding_control': 1,
            'choking_airway': 2,
            'burns_treatment': 3,
            'fractures_injury': 4,
            'heart_attack': 5,
            'stroke_neurological': 6,
            'poisoning_toxic': 7,
            'allergic_reaction': 8,
            'diabetic_emergency': 9,
            'seizures_convulsions': 10,
            'general_first_aid': 11
        }
        
        self.reverse_categories = {v: k for k, v in self.categories.items()}
        
        # Comprehensive training data for medical chatbot
        self.training_data = []
        
    def generate_training_data(self) -> List[Dict]:
        """Generate comprehensive training dataset"""
        
        # Emergency CPR queries
        cpr_queries = [
            "how to perform cpr",
            "cpr steps",
            "cardiopulmonary resuscitation",
            "what is cpr",
            "how to do cpr on adult",
            "cpr procedure",
            "chest compressions",
            "rescue breathing",
            "heart stopped beating",
            "person not breathing",
            "unconscious person no pulse",
            "cardiac arrest help",
            "how to save someone from heart attack",
            "cpr for dummies",
            "emergency cpr steps",
            "how to do mouth to mouth",
            "cpr compressions per minute",
            "when to start cpr",
            "cpr training",
            "cpr basics",
            "how to check pulse",
            "adult cpr protocol",
            "cpr ratio compressions to breaths",
            "hands only cpr",
            "cpr for healthcare providers",
            "cpr certification",
            "how to perform rescue breaths",
            "cpr depth inches",
            "cpr hand placement",
            "when to stop cpr",
            "cpr on elderly",
            "cpr for children",
            "cpr techniques",
            "basic life support",
            "cpr emergency response",
            "how to revive someone",
            "cpr first aid",
            "emergency response cpr",
            "cpr training online",
            "cpr procedure steps"
        ]
        
        # Bleeding control queries
        bleeding_queries = [
            "how to stop bleeding",
            "control bleeding",
            "stop blood loss",
            "severe bleeding help",
            "cut wound treatment",
            "how to bandage wound",
            "hemorrhage control",
            "blood coming out",
            "deep cut treatment",
            "how to apply pressure",
            "emergency bleeding control",
            "wound care",
            "how to treat cut",
            "stop bleeding fast",
            "bleeding from wound",
            "how to use tourniquet",
            "arterial bleeding",
            "venous bleeding",
            "internal bleeding",
            "external bleeding",
            "nosebleed treatment",
            "bleeding gums",
            "heavy menstrual bleeding",
            "how to elevate wound",
            "pressure points bleeding",
            "how to wrap bandage",
            "emergency wound care",
            "severe bleeding first aid",
            "blood loss symptoms",
            "how to stop nosebleed",
            "cuts and scrapes",
            "laceration treatment",
            "puncture wound",
            "bleeding control techniques",
            "first aid for cuts",
            "emergency bandage",
            "how to clean wound",
            "wound dressing",
            "bleeding emergency",
            "trauma bleeding",
            "how to treat hemorrhage"
        ]
        
        # Choking/airway queries
        choking_queries = [
            "someone is choking",
            "how to help choking person",
            "choking first aid",
            "heimlich maneuver",
            "back blows choking",
            "airway obstruction",
            "person can't breathe",
            "choking emergency",
            "how to clear airway",
            "choking rescue",
            "abdominal thrusts",
            "choking infant",
            "choking child",
            "choking adult",
            "foreign object airway",
            "choking response",
            "how to perform heimlich",
            "choking symptoms",
            "unable to speak choking",
            "choking cough",
            "choking treatment",
            "airway management",
            "choking prevention",
            "choking on food",
            "choking on object",
            "choking response steps",
            "back slap technique",
            "choking algorithm",
            "emergency choking help",
            "choking protocols",
            "choking first steps",
            "how to save choking victim",
            "choking rescue technique",
            "choking emergency response",
            "partial choking",
            "complete choking",
            "choking rescue procedure",
            "choking prevention tips",
            "choking safety",
            "choking recovery position",
            "choking aftermath"
        ]
        
        # Burns treatment queries
        burn_queries = [
            "how to treat burns",
            "burn treatment",
            "first degree burn",
            "second degree burn",
            "third degree burn",
            "chemical burn",
            "electrical burn",
            "thermal burn",
            "burn first aid",
            "how to cool burn",
            "burn emergency",
            "severe burn treatment",
            "burn pain relief",
            "burn blister care",
            "sunburn treatment",
            "burn dressing",
            "burn care at home",
            "burn infection prevention",
            "burn healing",
            "burn scar prevention",
            "burn assessment",
            "major burn",
            "minor burn",
            "burn emergency response",
            "burn victim care",
            "burn fluid replacement",
            "burn shock treatment",
            "burn inhalation injury",
            "burn electrical injury",
            "burn chemical injury",
            "burn thermal injury",
            "burn radiation injury",
            "burn debridement",
            "burn graft",
            "burn reconstruction",
            "burn rehabilitation",
            "burn prevention",
            "burn safety",
            "burn first steps",
            "burn emergency kit",
            "burn medical attention"
        ]
        
        # Fractures/injury queries
        fracture_queries = [
            "broken bone",
            "fracture treatment",
            "sprain vs fracture",
            "how to splint",
            "bone fracture",
            "compound fracture",
            "simple fracture",
            "fracture first aid",
            "broken arm",
            "broken leg",
            "broken finger",
            "fracture care",
            "how to immobilize",
            "fracture emergency",
            "dislocation treatment",
            "sprain treatment",
            "strain treatment",
            "fracture symptoms",
            "broken bone signs",
            "fracture healing",
            "fracture complications",
            "fracture reduction",
            "fracture cast",
            "fracture surgery",
            "fracture rehabilitation",
            "fracture prevention",
            "fracture types",
            "stress fracture",
            "pathological fracture",
            "fracture emergency care",
            "fracture first response",
            "how to support broken bone",
            "fracture pain management",
            "fracture swelling",
            "fracture bruising",
            "fracture deformity",
            "fracture medical attention",
            "fracture home care",
            "fracture exercise",
            "fracture recovery",
            "fracture complications"
        ]
        
        # Heart attack queries
        heart_attack_queries = [
            "heart attack symptoms",
            "heart attack signs",
            "chest pain heart attack",
            "heart attack emergency",
            "myocardial infarction",
            "heart attack first aid",
            "heart attack treatment",
            "heart attack prevention",
            "heart attack warning signs",
            "heart attack pain",
            "heart attack women",
            "heart attack men",
            "heart attack medication",
            "heart attack aspirin",
            "heart attack nitroglycerin",
            "heart attack oxygen",
            "heart attack position",
            "heart attack monitoring",
            "heart attack recovery",
            "heart attack rehabilitation",
            "heart attack risk factors",
            "heart attack prevention tips",
            "heart attack emergency response",
            "heart attack protocol",
            "heart attack algorithm",
            "heart attack assessment",
            "heart attack diagnosis",
            "heart attack complications",
            "heart attack statistics",
            "heart attack gender differences",
            "heart attack age factors",
            "heart attack lifestyle",
            "heart attack diet",
            "heart attack exercise",
            "heart attack stress",
            "heart attack smoking",
            "heart attack diabetes",
            "heart attack hypertension",
            "heart attack cholesterol",
            "heart attack family history",
            "heart attack sudden death"
        ]
        
        # Stroke queries
        stroke_queries = [
            "stroke symptoms",
            "stroke signs",
            "stroke emergency",
            "ischemic stroke",
            "hemorrhagic stroke",
            "mini stroke",
            "tia transient ischemic attack",
            "stroke FAST",
            "face drooping stroke",
            "arm weakness stroke",
            "speech difficulty stroke",
            "stroke first aid",
            "stroke treatment",
            "stroke prevention",
            "stroke recovery",
            "stroke rehabilitation",
            "stroke warning signs",
            "stroke brain attack",
            "stroke clot",
            "stroke bleeding",
            "stroke aphasia",
            "stroke paralysis",
            "stroke mobility",
            "stroke cognitive",
            "stroke communication",
            "stroke swallowing",
            "stroke consciousness",
            "stroke coma",
            "stroke death",
            "stroke prevention tips",
            "stroke risk factors",
            "stroke age",
            "stroke gender",
            "stroke race",
            "stroke family history",
            "stroke hypertension",
            "stroke diabetes",
            "stroke smoking",
            "stroke alcohol",
            "stroke diet",
            "stroke exercise",
            "stroke stress"
        ]
        
        # Poisoning queries
        poisoning_queries = [
            "poisoning emergency",
            "poison ingestion",
            "chemical poisoning",
            "drug overdose",
            "poison first aid",
            "how to induce vomiting",
            "activated charcoal",
            "poison control center",
            "toxic ingestion",
            "household poison",
            "industrial poison",
            "plant poisoning",
            "food poisoning",
            "alcohol poisoning",
            "carbon monoxide poisoning",
            "lead poisoning",
            "mercury poisoning",
            "arsenic poisoning",
            "cyanide poisoning",
            "pesticide poisoning",
            "medicine overdose",
            "accidental poisoning",
            "intentional poisoning",
            "poison symptoms",
            "poison treatment",
            "poison prevention",
            "poison antidote",
            "poison decontamination",
            "poison elimination",
            "poison absorption",
            "poison distribution",
            "poison metabolism",
            "poison excretion",
            "poison effects",
            "poison organs",
            "poison nervous system",
            "poison cardiovascular",
            "poison respiratory",
            "poison digestive",
            "poison skin",
            "poison eyes"
        ]
        
        # Allergic reaction queries
        allergy_queries = [
            "allergic reaction",
            "anaphylaxis",
            "allergy symptoms",
            "severe allergy",
            "food allergy",
            "medication allergy",
            "insect sting allergy",
            "latex allergy",
            "allergy emergency",
            "allergy treatment",
            "epipen use",
            "allergy medication",
            "antihistamine",
            "allergy prevention",
            "allergy testing",
            "allergy diagnosis",
            "allergy management",
            "allergy control",
            "allergy avoidance",
            "allergy triggers",
            "allergy history",
            "allergy family",
            "allergy children",
            "allergy adults",
            "allergy elderly",
            "allergy pregnancy",
            "allergy breastfeeding",
            "allergy travel",
            "allergy emergency kit",
            "allergy action plan",
            "allergy protocol",
            "allergy response",
            "allergy first aid",
            "allergy severity",
            "allergy mild",
            "allergy moderate",
            "allergy severe",
            "allergy life threatening",
            "allergy hives",
            "allergy swelling",
            "allergy breathing"
        ]
        
        # Diabetic emergency queries
        diabetic_queries = [
            "diabetic emergency",
            "low blood sugar",
            "high blood sugar",
            "hypoglycemia",
            "hyperglycemia",
            "diabetic coma",
            "insulin shock",
            "diabetic ketoacidosis",
            "blood glucose emergency",
            "diabetes symptoms",
            "diabetes treatment",
            "diabetes medication",
            "insulin injection",
            "diabetes monitoring",
            "diabetes prevention",
            "diabetes management",
            "diabetes control",
            "diabetes education",
            "diabetes diet",
            "diabetes exercise",
            "diabetes complications",
            "diabetes type 1",
            "diabetes type 2",
            "gestational diabetes",
            "prediabetes",
            "diabetes warning signs",
            "diabetes emergency signs",
            "diabetes first aid",
            "diabetes response",
            "diabetes protocol",
            "diabetes algorithm",
            "diabetes assessment",
            "diabetes evaluation",
            "diabetes testing",
            "diabetes glucose meter",
            "diabetes ketone strips",
            "diabetes glucagon",
            "diabetes emergency kit",
            "diabetes action plan",
            "diabetes support",
            "diabetes resources"
        ]
        
        # Seizure queries
        seizure_queries = [
            "seizure emergency",
            "epileptic seizure",
            "seizure first aid",
            "convulsion",
            "seizure symptoms",
            "seizure types",
            "grand mal seizure",
            "petit mal seizure",
            "partial seizure",
            "generalized seizure",
            "focal seizure",
            "seizure treatment",
            "seizure medication",
            "seizure prevention",
            "seizure recovery",
            "seizure safety",
            "seizure precautions",
            "seizure triggers",
            "seizure causes",
            "seizure diagnosis",
            "seizure management",
            "seizure control",
            "seizure monitoring",
            "seizure emergency response",
            "seizure protocol",
            "seizure algorithm",
            "seizure assessment",
            "seizure evaluation",
            "seizure classification",
            "seizure duration",
            "seizure frequency",
            "seizure warning",
            "seizure aura",
            "seizure postictal",
            "seizure recovery position",
            "seizure airway",
            "seizure breathing",
            "seizure circulation",
            "seizure injury",
            "seizure head trauma"
        ]
        
        # General first aid queries
        general_queries = [
            "first aid basics",
            "emergency first aid",
            "basic first aid",
            "first aid kit",
            "first aid training",
            "first aid certification",
            "first aid procedures",
            "first aid techniques",
            "first aid principles",
            "first aid assessment",
            "first aid evaluation",
            "first aid response",
            "first aid priority",
            "first aid ABC",
            "first aid survey",
            "first aid examination",
            "first aid treatment",
            "first aid care",
            "first aid management",
            "first aid intervention",
            "first aid stabilization",
            "first aid transport",
            "first aid hospital",
            "first aid doctor",
            "first aid ambulance",
            "first aid emergency services",
            "first aid prevention",
            "first aid safety",
            "first aid hazards",
            "first aid risks",
            "first aid complications",
            "first aid follow up",
            "first aid documentation",
            "first aid communication",
            "first aid teamwork",
            "first aid leadership",
            "first aid psychology",
            "first aid stress",
            "first aid coping",
            "first aid resources",
            "first aid information"
        ]
        
        # Combine all data with labels
        all_queries = [
            (cpr_queries, 'emergency_cpr'),
            (bleeding_queries, 'bleeding_control'),
            (choking_queries, 'choking_airway'),
            (burn_queries, 'burns_treatment'),
            (fracture_queries, 'fractures_injury'),
            (heart_attack_queries, 'heart_attack'),
            (stroke_queries, 'stroke_neurological'),
            (poisoning_queries, 'poisoning_toxic'),
            (allergy_queries, 'allergic_reaction'),
            (diabetic_queries, 'diabetic_emergency'),
            (seizure_queries, 'seizures_convulsions'),
            (general_queries, 'general_first_aid')
        ]
        
        # Generate training data
        for query_list, category in all_queries:
            for query in query_list:
                self.training_data.append({
                    'text': query.lower().strip(),
                    'category': category,
                    'label': self.categories[category]
                })
        
        return self.training_data
    
    def save_dataset(self, filename: str = 'medical_chatbot_training_data.json'):
        """Save training dataset to JSON file"""
        data = {
            'categories': self.categories,
            'reverse_categories': self.reverse_categories,
            'training_data': self.generate_training_data(),
            'metadata': {
                'total_samples': len(self.training_data),
                'categories_count': len(self.categories),
                'description': 'Medical Chatbot Training Dataset for Emergency Medical Classification'
            }
        }
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print(f"Dataset saved to {filename}")
        print(f"Total samples: {data['metadata']['total_samples']}")
        print(f"Categories: {len(self.categories)}")
        
        # Print distribution
        category_counts = {}
        for item in self.training_data:
            category = item['category']
            category_counts[category] = category_counts.get(category, 0) + 1
        
        print("\nCategory distribution:")
        for category, count in category_counts.items():
            print(f"  {category}: {count} samples")
        
        return filename
    
    def generate_validation_split(self, validation_ratio: float = 0.2) -> Tuple[List[Dict], List[Dict]]:
        """Generate train/validation split"""
        random.seed(42)  # For reproducible results
        random.shuffle(self.training_data)
        
        split_point = int(len(self.training_data) * (1 - validation_ratio))
        train_data = self.training_data[:split_point]
        val_data = self.training_data[split_point:]
        
        return train_data, val_data

def main():
    """Generate and save medical chatbot training dataset"""
    generator = MedicalChatbotDatasetGenerator()
    
    # Generate and save main dataset
    dataset_file = generator.save_dataset()
    
    # Generate train/validation split
    train_data, val_data = generator.generate_validation_split()
    
    # Save splits
    with open('train_data.json', 'w', encoding='utf-8') as f:
        json.dump(train_data, f, indent=2, ensure_ascii=False)
    
    with open('validation_data.json', 'w', encoding='utf-8') as f:
        json.dump(val_data, f, indent=2, ensure_ascii=False)
    
    print(f"\nTrain samples: {len(train_data)}")
    print(f"Validation samples: {len(val_data)}")
    print("\nDataset generation complete!")

if __name__ == "__main__":
    main()
