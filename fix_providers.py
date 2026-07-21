import os
import re

files_to_fix = [
    'lib/shared/providers/customer_provider.dart',
    'lib/shared/providers/order_provider.dart',
    'lib/shared/providers/fabric_provider.dart',
    'lib/shared/providers/design_provider.dart',
    'lib/shared/providers/garment_provider.dart'
]

for filepath in files_to_fix:
    if not os.path.exists(filepath):
        continue
        
    with open(filepath, 'r') as f:
        content = f.read()

    # CustomerProvider
    if 'customer_provider.dart' in filepath:
        content = content.replace("action: 'Created', type: 'Client', name: customer.name", "action: 'Created', type: 'Client', name: customer.name, referenceId: customer.id, clientId: customer.id, clientName: customer.name")
        content = content.replace("action: 'Updated', type: 'Client', name: customer.name", "action: 'Updated', type: 'Client', name: customer.name, referenceId: customer.id, clientId: customer.id, clientName: customer.name")
        content = content.replace("action: 'Deleted', type: 'Client', name: customer.name", "action: 'Deleted', type: 'Client', name: customer.name, referenceId: customer.id, clientId: customer.id, clientName: customer.name")
    
    # OrderProvider
    elif 'order_provider.dart' in filepath:
        content = content.replace("action: 'Created', type: 'Order', name: order.orderNumber", "action: 'Created', type: 'Order', name: order.orderNumber, referenceId: order.id, orderId: order.id, clientId: order.customerId, clientName: order.customerName")
        content = content.replace("action: 'Updated', type: 'Order', name: order.orderNumber", "action: 'Updated', type: 'Order', name: order.orderNumber, referenceId: order.id, orderId: order.id, clientId: order.customerId, clientName: order.customerName")
        content = content.replace("action: 'Deleted', type: 'Order', name: order.orderNumber", "action: 'Deleted', type: 'Order', name: order.orderNumber, referenceId: order.id, orderId: order.id, clientId: order.customerId, clientName: order.customerName")
        
    # FabricProvider
    elif 'fabric_provider.dart' in filepath:
        content = content.replace("action: 'Created', type: 'Fabric', name: fabric.name", "action: 'Created', type: 'Fabric', name: fabric.name, referenceId: fabric.id")
        content = content.replace("action: 'Updated', type: 'Fabric', name: fabric.name", "action: 'Updated', type: 'Fabric', name: fabric.name, referenceId: fabric.id")
        content = content.replace("action: 'Deleted', type: 'Fabric', name: fabric.name", "action: 'Deleted', type: 'Fabric', name: fabric.name, referenceId: fabric.id")
        
    # DesignProvider
    elif 'design_provider.dart' in filepath:
        content = content.replace("action: 'Created', type: 'Design', name: design.name", "action: 'Created', type: 'Design', name: design.name, referenceId: design.id")
        content = content.replace("action: 'Updated', type: 'Design', name: design.name", "action: 'Updated', type: 'Design', name: design.name, referenceId: design.id")
        content = content.replace("action: 'Deleted', type: 'Design', name: design.name", "action: 'Deleted', type: 'Design', name: design.name, referenceId: design.id")
        
    # GarmentProvider
    elif 'garment_provider.dart' in filepath:
        content = content.replace("action: 'Created', type: 'Garment', name: garment.name", "action: 'Created', type: 'Garment', name: garment.name, referenceId: garment.id")
        content = content.replace("action: 'Updated', type: 'Garment', name: garment.name", "action: 'Updated', type: 'Garment', name: garment.name, referenceId: garment.id")
        content = content.replace("action: 'Deleted', type: 'Garment', name: garment.name", "action: 'Deleted', type: 'Garment', name: garment.name, referenceId: garment.id")
        
    with open(filepath, 'w') as f:
        f.write(content)
        
    print(f"Updated {filepath}")
