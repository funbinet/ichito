import os

files_to_fix = [
    'lib/features/notes/data/repositories/note_repository.dart',
    'lib/features/garments/data/repositories/materials_repository.dart',
    'lib/features/garments/data/repositories/garment_repository.dart'
]

for filepath in files_to_fix:
    if not os.path.exists(filepath):
        continue
        
    with open(filepath, 'r') as f:
        content = f.read()

    # Note
    if 'note_repository.dart' in filepath:
        content = content.replace("action: 'Created', type: 'Note', name: note.title", "action: 'Created', type: 'Note', name: note.title, referenceId: note.id")
        content = content.replace("action: 'Updated', type: 'Note', name: note.title", "action: 'Updated', type: 'Note', name: note.title, referenceId: note.id")
        content = content.replace("action: 'Deleted', type: 'Note', name: note.title", "action: 'Deleted', type: 'Note', name: note.title, referenceId: note.id")
    
    # Materials
    elif 'materials_repository.dart' in filepath:
        content = content.replace("action: 'Created', type: 'Fabric', name: fabric.name", "action: 'Created', type: 'Fabric', name: fabric.name, referenceId: fabric.id")
        content = content.replace("action: 'Updated', type: 'Fabric', name: fabric.name", "action: 'Updated', type: 'Fabric', name: fabric.name, referenceId: fabric.id")
        content = content.replace("action: 'Deleted', type: 'Fabric', name: fabric.name", "action: 'Deleted', type: 'Fabric', name: fabric.name, referenceId: fabric.id")
        content = content.replace("action: 'Created', type: 'Design', name: design.name", "action: 'Created', type: 'Design', name: design.name, referenceId: design.id")
        content = content.replace("action: 'Updated', type: 'Design', name: design.name", "action: 'Updated', type: 'Design', name: design.name, referenceId: design.id")
        content = content.replace("action: 'Deleted', type: 'Design', name: design.name", "action: 'Deleted', type: 'Design', name: design.name, referenceId: design.id")
        
    # Garment
    elif 'garment_repository.dart' in filepath:
        content = content.replace("action: 'Created', type: 'Garment', name: garment.name", "action: 'Created', type: 'Garment', name: garment.name, referenceId: garment.id")
        content = content.replace("action: 'Updated', type: 'Garment', name: garment.name", "action: 'Updated', type: 'Garment', name: garment.name, referenceId: garment.id")
        content = content.replace("action: 'Deleted', type: 'Garment', name: garment.name", "action: 'Deleted', type: 'Garment', name: garment.name, referenceId: garment.id")
        
    with open(filepath, 'w') as f:
        f.write(content)
        
    print(f"Updated {filepath}")
