#!/usr/bin/env python3
"""
Medical Chatbot Data Preparation Script
Generates training data and vocabulary for ML model
"""

import json
import os
import re
import numpy as np
from typing import List, Dict, Tuple
from collections import Counter, defaultdict
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class MedicalDataPreparator:
    def __init__(self, data_dir: str):
        self.data_dir = data_dir
        self.medical_data = {
            "cardiac_arrest": {
                "keywords": ["cardiac arrest", "heart stopped", "no pulse", "unresponsive", "cpr", "chest compressions"],
                "training_texts": [
                    "person collapsed and has no pulse",
                    "someone is unconscious and not breathing",
                    "heart attack emergency help needed",
                    "how to perform CPR chest compressions",
                    "cardiac arrest what to do",
                    "person collapsed not breathing",
                    "emergency cardiac massage instructions",
                    "heart stopped beating what to do",
                    "no breathing and no pulse",
                    "unresponsive person cardiac emergency",
                    "cpr procedure for heart stopped",
                    "heart attack and unconscious",
                    "emergency heart massage technique",
                    "cardiac arrest first aid steps",
                    "unconscious person no breathing"
                ]
            },
            "choking": {
                "keywords": ["choking", "cannot breathe", "airway blocked", "heimlich maneuver"],
                "training_texts": [
                    "someone is choking and cannot breathe",
                    "how to help choking person",
                    "airway blocked emergency help",
                    "heimlich maneuver how to perform",
                    "person choking what to do",
                    "cannot breathe choking emergency",
                    "foreign object in throat help",
                    "airway obstruction what to do",
                    "choking first aid instructions",
                    "heimlich maneuver technique",
                    "someone coughing cannot breathe",
                    "airway blocked emergency response",
                    "choking emergency procedure",
                    "how to clear blocked airway",
                    "person choking for help"
                ]
            },
            "bleeding": {
                "keywords": ["bleeding", "cut", "wound", "hemorrhage", "blood loss"],
                "training_texts": [
                    "heavy bleeding from cut wound",
                    "how to stop bleeding emergency",
                    "wound bleeding heavily what to do",
                    "blood loss emergency treatment",
                    "severe bleeding how to control",
                    "cut with heavy bleeding",
                    "hemorrhage emergency help",
                    "wound bleeding won't stop",
                    "severe cut bleeding control",
                    "blood loss from injury",
                    "emergency bleeding control",
                    "heavy bleeding first aid",
                    "cut artery bleeding",
                    "wound hemorrhage treatment",
                    "bleeding control techniques"
                ]
            },
            "burns": {
                "keywords": ["burn", "burned", "fire", "scald", "burn injury"],
                "training_texts": [
                    "person burned by fire or hot object",
                    "how to treat burn injuries",
                    "severe burn emergency treatment",
                    "fire burn what to do",
                    "hot liquid scald injury",
                    "chemical burn emergency help",
                    "burn blister formation treatment",
                    "electrical burn emergency care",
                    "sunburn severe treatment",
                    "burn pain management",
                    "burn wound care instructions",
                    "severe burn first aid",
                    "burn classification treatment",
                    "burn emergency response",
                    "hot object burn injury"
                ]
            },
            "fracture": {
                "keywords": ["fracture", "broken bone", "fractured", "bone broken"],
                "training_texts": [
                    "suspected broken bone fracture",
                    "how to treat bone fracture",
                    "broken bone emergency care",
                    "fracture splinting techniques",
                    "suspected fractured arm or leg",
                    "broken bone what to do",
                    "fracture immobilization method",
                    "bone fracture first aid",
                    "broken bone emergency treatment",
                    "fracture stabilization techniques",
                    "suspected spinal fracture",
                    "broken bone pain management",
                    "fracture emergency response",
                    "bone injury treatment",
                    "fracture immobilization procedure"
                ]
            },
            "poisoning": {
                "keywords": ["poison", "toxic", "ingestion", "chemical poisoning"],
                "training_texts": [
                    "someone accidentally swallowed poison",
                    "chemical poisoning emergency help",
                    "toxic ingestion what to do",
                    "poison control emergency number",
                    "drug overdose emergency help",
                    "carbon monoxide poisoning symptoms",
                    "food poisoning severe symptoms",
                    "chemical inhalation poisoning",
                    "poison antidote emergency",
                    "toxic substance exposure",
                    "accidental poisoning treatment",
                    "poisoning emergency response",
                    "chemical burn from poison",
                    "ingested toxic substance",
                    "poison control center help"
                ]
            },
            "allergic_reaction": {
                "keywords": ["allergy", "anaphylaxis", "allergic", "hives", "swelling"],
                "training_texts": [
                    "severe allergic reaction anaphylaxis",
                    "person having allergic reaction",
                    "anaphylactic shock emergency",
                    "severe allergic response help",
                    "allergy attack what to do",
                    "swelling from allergic reaction",
                    "hives and difficulty breathing",
                    "allergic shock emergency",
                    "severe allergy attack",
                    "anaphylaxis symptoms treatment",
                    "allergic reaction swelling",
                    "food allergy emergency",
                    "insect sting allergic reaction",
                    "allergy medication emergency",
                    "severe allergic response"
                ]
            },
            "seizure": {
                "keywords": ["seizure", "convulsion", "epilepsy", "fits", "shaking"],
                "training_texts": [
                    "person having seizure convulsion",
                    "epileptic seizure emergency help",
                    "convulsions what to do",
                    "seizure first aid instructions",
                    "person shaking uncontrollably",
                    "epilepsy attack emergency",
                    "seizure duration how long",
                    "convulsion safety measures",
                    "seizure aftercare treatment",
                    "epileptic fit help",
                    "seizure emergency response",
                    "convulsive episode care",
                    "seizure protection during",
                    "epilepsy emergency protocol",
                    "seizure first aid procedure"
                ]
            },
            "stroke": {
                "keywords": ["stroke", "brain attack", "paralysis", "slurred speech"],
                "training_texts": [
                    "suspected stroke symptoms help",
                    "brain attack emergency signs",
                    "stroke facial drooping treatment",
                    "slurred speech stroke symptoms",
                    "stroke paralysis emergency",
                    "brain stroke what to do",
                    "stroke warning signs help",
                    "cerebrovascular accident emergency",
                    "strokeFAST test procedure",
                    "ischemic stroke treatment",
                    "hemorrhagic stroke emergency",
                    "stroke patient care",
                    "stroke recognition signs",
                    "brain attack emergency response",
                    "stroke emergency protocol"
                ]
            },
            "diabetic_emergency": {
                "keywords": ["diabetic", "blood sugar", "hypoglycemia", "insulin"],
                "training_texts": [
                    "diabetic emergency low blood sugar",
                    "hypoglycemic episode help",
                    "diabetic coma emergency",
                    "blood sugar too low help",
                    "insulin shock treatment",
                    "diabetic ketoacidosis emergency",
                    "diabetic seizure from low sugar",
                    "blood glucose emergency low",
                    "diabetic emergency treatment",
                    "insulin reaction help",
                    "severe hypoglycemia treatment",
                    "diabetic emergency signs",
                    "blood sugar emergency high",
                    "diabetic emergency protocol",
                    "insulin overdose emergency"
                ]
            },
            "breathing_difficulty": {
                "keywords": ["breathing", "respiratory", "asthma", "cannot breathe", "shortness of breath"],
                "training_texts": [
                    "difficulty breathing emergency",
                    "cannot breathe properly help",
                    "respiratory distress treatment",
                    "asthma attack emergency",
                    "shortness of breath severe",
                    "breathing problems emergency",
                    "respiratory failure help",
                    "chest breathing difficulty",
                    "asthma emergency inhaler",
                    "breathing obstruction help",
                    "severe breathing problems",
                    "respiratory emergency treatment",
                    "difficulty breathing first aid",
                    "breathing distress protocol",
                    "respiratory emergency response"
                ]
            },
            "heat_exhaustion": {
                "keywords": ["heat", "exhaustion", "dehydration", "hot weather", "sun"],
                "training_texts": [
                    "heat exhaustion from hot weather",
                    "dehydration emergency symptoms",
                    "heat stroke prevention help",
                    "hot weather illness treatment",
                    "severe heat exhaustion",
                    "heat cramps emergency care",
                    "dehydration from heat",
                    "sun exposure emergency",
                    "heat illness symptoms",
                    "hot weather safety",
                    "heat exhaustion treatment",
                    "dehydration emergency help",
                    "heat related illness",
                    "sun exposure treatment",
                    "heat emergency protocol"
                ]
            },
            "hypothermia": {
                "keywords": ["cold", "hypothermia", "frostbite", "freezing", "exposure"],
                "training_texts": [
                    "severe hypothermia from cold",
                    "frostbite emergency treatment",
                    "cold exposure emergency",
                    "freezing temperature injury",
                    "hypothermia symptoms help",
                    "cold weather emergency",
                    "frostbite first aid",
                    "hypothermia warming treatment",
                    "exposure to cold emergency",
                    "freezing injury treatment",
                    "severe cold exposure",
                    "hypothermia emergency care",
                    "frostbite emergency protocol",
                    "cold weather safety",
                    "hypothermia warming procedure"
                ]
            },
            "head_injury": {
                "keywords": ["head injury", "concussion", "head trauma", "head wound"],
                "training_texts": [
                    "head injury concussion emergency",
                    "head trauma what to do",
                    "concussion symptoms treatment",
                    "head wound bleeding emergency",
                    "severe head injury help",
                    "brain injury emergency",
                    "head impact concussion",
                    "skull fracture emergency",
                    "head injury monitoring",
                    "concussion recovery care",
                    "head trauma assessment",
                    "severe head wound help",
                    "brain injury treatment",
                    "head injury first aid",
                    "concussion emergency protocol"
                ]
            },
            "eye_injury": {
                "keywords": ["eye injury", "eye damage", "vision", "eye trauma"],
                "training_texts": [
                    "eye injury emergency help",
                    "eye trauma what to do",
                    "chemical eye exposure",
                    "eye wound emergency care",
                    "vision loss emergency",
                    "eye foreign object help",
                    "eye burn emergency treatment",
                    "eye injury first aid",
                    "vision problems emergency",
                    "eye damage treatment",
                    "eye trauma emergency",
                    "eye injury assessment",
                    "severe eye injury",
                    "eye emergency protocol",
                    "eye care emergency"
                ]
            },
            "electric_shock": {
                "keywords": ["electric", "shock", "electrocution", "electrical", "current"],
                "training_texts": [
                    "electrical shock emergency help",
                    "electrocution what to do",
                    "electric current injury",
                    "high voltage shock emergency",
                    "electrical burn treatment",
                    "electric shock symptoms",
                    "lightning strike emergency",
                    "electrical injury care",
                    "shock from electricity",
                    "electric accident help",
                    "electrical emergency response",
                    "electric shock first aid",
                    "electrocution treatment",
                    "electrical injury protocol",
                    "electric shock safety"
                ]
            }
        }
        
    def generate_training_data(self) -> List[Dict]:
        """Generate comprehensive training data"""
        logger.info("Generating training data...")
        
        training_data = []
        
        # Add original data
        for category, data in self.medical_data.items():
            label = self._get_label_for_category(category)
            
            for text in data["training_texts"]:
                training_data.append({
                    "text": text,
                    "label": label,
                    "category": category
                })
        
        # Add keyword variations
        for category, data in self.medical_data.items():
            label = self._get_label_for_category(category)
            
            for keyword in data["keywords"]:
                # Generate variations
                variations = self._generate_variations(keyword)
                for variation in variations:
                    training_data.append({
                        "text": variation,
                        "label": label,
                        "category": category
                    })
        
        # Add synthetic data for balance
        training_data = self._add_synthetic_data(training_data)
        
        logger.info(f"Generated {len(training_data)} training samples")
        return training_data
    
    def _generate_variations(self, keyword: str) -> List[str]:
        """Generate text variations for a keyword"""
        variations = []
        
        # Add question variations
        variations.extend([
            f"help with {keyword}",
            f"what to do for {keyword}",
            f"{keyword} emergency",
            f"treatment for {keyword}",
            f"how to handle {keyword}",
            f"{keyword} symptoms",
            f"{keyword} first aid",
            f"{keyword} medical help",
            f"emergency {keyword}",
            f"urgent {keyword} help"
        ])
        
        # Add longer contextual variations
        variations.extend([
            f"i need help with {keyword} situation",
            f"someone is experiencing {keyword}",
            f"emergency situation with {keyword}",
            f"medical emergency {keyword} case",
            f"urgent medical help {keyword}"
        ])
        
        return variations[:10]  # Limit to 10 variations
    
    def _add_synthetic_data(self, training_data: List[Dict]) -> List[Dict]:
        """Add synthetic data to balance classes"""
        category_counts = defaultdict(int)
        for item in training_data:
            category_counts[item["category"]] += 1
        
        max_samples = max(category_counts.values())
        target_samples = min(max_samples, 500)  # Cap at 500 per class
        
        synthetic_data = []
        
        for category, data in self.medical_data.items():
            current_count = category_counts[category]
            needed = target_samples - current_count
            
            if needed > 0:
                label = self._get_label_for_category(category)
                
                # Generate synthetic texts
                synthetic_texts = self._generate_synthetic_texts(data["keywords"], needed)
                
                for text in synthetic_texts:
                    synthetic_data.append({
                        "text": text,
                        "label": label,
                        "category": category,
                        "synthetic": True
                    })
        
        return training_data + synthetic_data
    
    def _generate_synthetic_texts(self, keywords: List[str], count: int) -> List[str]:
        """Generate synthetic training texts"""
        templates = [
            "emergency situation with {keyword}",
            "medical emergency {keyword}",
            "urgent help needed {keyword}",
            "serious {keyword} case",
            "critical {keyword} situation",
            "severe {keyword} emergency",
            "patient with {keyword}",
            "case of {keyword} emergency",
            "{keyword} medical emergency",
            "emergency response {keyword}",
            "immediate help {keyword}",
            "emergency care {keyword}",
            "urgent medical {keyword}",
            "emergency protocol {keyword}",
            "critical care {keyword}"
        ]
        
        synthetic_texts = []
        
        for i in range(count):
            keyword = keywords[i % len(keywords)]
            template = templates[i % len(templates)]
            text = template.format(keyword=keyword)
            
            # Add some randomization
            if i % 3 == 0:
                text = f"serious {text}"
            elif i % 3 == 1:
                text = f"urgent {text}"
            
            synthetic_texts.append(text)
        
        return synthetic_texts
    
    def _get_label_for_category(self, category: str) -> int:
        """Get numeric label for category"""
        category_labels = {
            "cardiac_arrest": 0, "choking": 1, "bleeding": 2, "burns": 3,
            "fracture": 4, "poisoning": 5, "allergic_reaction": 6,
            "seizure": 7, "stroke": 8, "diabetic_emergency": 9,
            "breathing_difficulty": 10, "heat_exhaustion": 11,
            "hypothermia": 12, "head_injury": 13, "eye_injury": 14,
            "electric_shock": 15
        }
        return category_labels.get(category, 0)
    
    def build_vocabulary(self, training_data: List[Dict]) -> Dict[str, int]:
        """Build vocabulary from training data"""
        logger.info("Building vocabulary...")
        
        # Extract all text
        all_text = []
        for item in training_data:
            # Clean and tokenize text
            text = re.sub(r'[^\w\s]', '', item["text"].lower())
            tokens = text.split()
            all_text.extend(tokens)
        
        # Count word frequencies
        word_counts = Counter(all_text)
        
        # Create vocabulary with special tokens
        vocab = {
            "<PAD>": 0,
            "<UNK>": 1,
            "<START>": 2,
            "<END>": 3
        }
        
        # Add words by frequency (excluding rare words)
        vocab_size = 10000
        for word, count in word_counts.most_common(vocab_size - 4):
            if count >= 2:  # Only include words that appear at least twice
                vocab[word] = len(vocab)
        
        logger.info(f"Built vocabulary with {len(vocab)} words")
        return vocab
    
    def save_data(self, training_data: List[Dict], vocabulary: Dict[str, int]):
        """Save training data and vocabulary"""
        # Create data directory
        os.makedirs(self.data_dir, exist_ok=True)
        
        # Save training data
        training_path = os.path.join(self.data_dir, "medical_training_data.json")
        with open(training_path, 'w', encoding='utf-8') as f:
            json.dump(training_data, f, indent=2, ensure_ascii=False)
        
        # Save vocabulary
        vocab_path = os.path.join(self.data_dir, "vocabulary.json")
        with open(vocab_path, 'w', encoding='utf-8') as f:
            json.dump(vocabulary, f, indent=2, ensure_ascii=False)
        
        # Save class information
        class_info = {
            "num_classes": 16,
            "class_names": [
                "cardiac_arrest", "choking", "bleeding", "burns", "fracture",
                "poisoning", "allergic_reaction", "seizure", "stroke", 
                "diabetic_emergency", "breathing_difficulty", "heat_exhaustion",
                "hypothermia", "head_injury", "eye_injury", "electric_shock"
            ],
            "class_labels": {
                "cardiac_arrest": 0, "choking": 1, "bleeding": 2, "burns": 3,
                "fracture": 4, "poisoning": 5, "allergic_reaction": 6,
                "seizure": 7, "stroke": 8, "diabetic_emergency": 9,
                "breathing_difficulty": 10, "heat_exhaustion": 11,
                "hypothermia": 12, "head_injury": 13, "eye_injury": 14,
                "electric_shock": 15
            }
        }
        
        class_path = os.path.join(self.data_dir, "class_info.json")
        with open(class_path, 'w', encoding='utf-8') as f:
            json.dump(class_info, f, indent=2, ensure_ascii=False)
        
        logger.info(f"Training data saved to: {training_path}")
        logger.info(f"Vocabulary saved to: {vocab_path}")
        logger.info(f"Class info saved to: {class_path}")
    
    def print_data_statistics(self, training_data: List[Dict]):
        """Print data statistics"""
        print("\nTraining Data Statistics:")
        print("=" * 50)
        
        # Count by category
        category_counts = defaultdict(int)
        for item in training_data:
            category_counts[item["category"]] += 1
        
        print(f"Total samples: {len(training_data)}")
        print(f"Number of categories: {len(category_counts)}")
        print("\nSamples per category:")
        
        for category, count in sorted(category_counts.items()):
            print(f"  {category}: {count}")
        
        # Text length statistics
        text_lengths = [len(item["text"].split()) for item in training_data]
        print(f"\nText length statistics:")
        print(f"  Average words: {np.mean(text_lengths):.2f}")
        print(f"  Min words: {min(text_lengths)}")
        print(f"  Max words: {max(text_lengths)}")
        print(f"  Median words: {np.median(text_lengths):.2f}")

def main():
    """Main function"""
    import numpy as np
    
    # Configuration
    data_dir = "data"
    
    # Create preparator
    preparator = MedicalDataPreparator(data_dir)
    
    # Generate training data
    training_data = preparator.generate_training_data()
    
    # Build vocabulary
    vocabulary = preparator.build_vocabulary(training_data)
    
    # Save data
    preparator.save_data(training_data, vocabulary)
    
    # Print statistics
    preparator.print_data_statistics(training_data)
    
    print(f"\n[SUCCESS] Data preparation completed!")
    print(f"Training data: {len(training_data)} samples")
    print(f"Vocabulary size: {len(vocabulary)} words")

if __name__ == "__main__":
    main()