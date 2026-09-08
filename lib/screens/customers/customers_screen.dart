import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/customer.dart';
import '../../services/customer_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerService _customerService = CustomerService();

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // FILTER CUSTOMERS
  // ============================================================

  List<Customer> _filterCustomers(List<Customer> customers) {
    if (_searchQuery.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final name = customer.name.toLowerCase();

      return name.contains(_searchQuery);
    }).toList();
  }

  // ============================================================
  // CUSTOMER DETAILS
  // ============================================================

  void _openCustomerDetails(Customer customer) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomerDetailsDialog(
          customer: customer,
          onUpdated: () {
            Navigator.pop(context);
          },
          onDeleted: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // ============================================================
  // BUILD CUSTOMER CARD
  // ============================================================

  Widget _buildCustomerCard(Customer customer) {
    final initial = customer.name.isNotEmpty
        ? customer.name[0].toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openCustomerDetails(customer),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // --------------------------------------------------
              // AVATAR
              // --------------------------------------------------
              CircleAvatar(
                radius: 27,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // --------------------------------------------------
              // CUSTOMER INFO
              // --------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name.isEmpty
                          ? 'Unnamed Customer'
                          : customer.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 15),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.phoneNumber.isEmpty
                                ? 'No phone number'
                                : customer.phoneNumber,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (customer.email != null &&
                        customer.email!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 15),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customer.email!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search customer by name...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState({required bool searching}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            searching ? Icons.person_search_outlined : Icons.people_outline,
            size: 70,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 16),

          Text(
            searching ? 'No customers found' : 'No customers yet',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            searching
                ? 'Try another customer name.'
                : 'Customers registered through CinemaApp will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Customer>>(
        stream: _customerService.getCustomers(),
        builder: (context, snapshot) {
          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 55),

                    const SizedBox(height: 15),

                    const Text(
                      'Failed to load customers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text('${snapshot.error}', textAlign: TextAlign.center),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allCustomers = snapshot.data ?? [];

          final customers = _filterCustomers(allCustomers);

          return Column(
            children: [
              // --------------------------------------------------
              // TOP AREA
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline, size: 28),

                    const SizedBox(width: 12),

                    const Text(
                      'Customers',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${allCustomers.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // SEARCH
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: _searchBar(),
              ),

              // --------------------------------------------------
              // RESULTS
              // --------------------------------------------------
              Expanded(
                child: customers.isEmpty
                    ? _emptyState(searching: _searchQuery.isNotEmpty)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          return _buildCustomerCard(customers[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================================================================
// CUSTOMER DETAILS DIALOG
// ==================================================================

class CustomerDetailsDialog extends StatefulWidget {
  final Customer customer;
  final VoidCallback onUpdated;
  final VoidCallback onDeleted;

  const CustomerDetailsDialog({
    super.key,
    required this.customer,
    required this.onUpdated,
    required this.onDeleted,
  });

  @override
  State<CustomerDetailsDialog> createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends State<CustomerDetailsDialog> {
  final CustomerService _customerService = CustomerService();

  bool _deleting = false;

  // ============================================================
  // DELETE CUSTOMER
  // ============================================================

  Future<void> _deleteCustomer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete '
            '"${widget.customer.name}"?\n\n'
            'This will permanently remove the customer profile '
            'from Firestore.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _deleting = true;
    });

    try {
      await _customerService.deleteCustomer(widget.customer.id);

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.customer.name} deleted successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _deleting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete customer: $e')));
    }
  }

  // ============================================================
  // EDIT CUSTOMER
  // ============================================================

  Future<void> _editCustomer() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return EditCustomerDialog(customer: widget.customer);
      },
    );

    if (result == true && mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer updated successfully.')),
      );
    }
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),

          const SizedBox(width: 12),

          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;

    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              customer.name.isEmpty ? 'Customer Details' : customer.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Customer ID', customer.id, Icons.badge_outlined),

              _detailRow('Name', customer.name, Icons.person_outline),

              _detailRow('Phone', customer.phoneNumber, Icons.phone_outlined),

              if (customer.email != null)
                _detailRow('Email', customer.email!, Icons.email_outlined),

              if (customer.createdAt != null)
                _detailRow(
                  'Created',
                  _formatDate(customer.createdAt!),
                  Icons.calendar_today_outlined,
                ),

              const Divider(),

              const SizedBox(height: 10),

              const Text(
                'Firestore Data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              ...customer.data.entries.map((entry) {
                return _detailRow(
                  entry.key,
                  _formatValue(entry.value),
                  Icons.data_object,
                );
              }),
            ],
          ),
        ),
      ),

      actions: [
        TextButton.icon(
          onPressed: _deleting ? null : _deleteCustomer,
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          label: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),

        const Spacer(),

        TextButton(
          onPressed: _deleting
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Close'),
        ),

        ElevatedButton.icon(
          onPressed: _deleting ? null : _editCustomer,
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return 'null';
    }

    if (value is Timestamp) {
      return _formatDate(value.toDate());
    }

    if (value is List) {
      return value.join(', ');
    }

    if (value is Map) {
      return value.toString();
    }

    return value.toString();
  }
}

// ==================================================================
// EDIT CUSTOMER DIALOG
// ==================================================================

class EditCustomerDialog extends StatefulWidget {
  final Customer customer;

  const EditCustomerDialog({super.key, required this.customer});

  @override
  State<EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<EditCustomerDialog> {
  final CustomerService _customerService = CustomerService();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  final _formKey = GlobalKey<FormState>();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.customer.name);

    _phoneController = TextEditingController(text: widget.customer.phoneNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _customerService.updateCustomer(
        customerId: widget.customer.id,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update customer: $e')));
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Customer'),

      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter customer name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _phoneController,
                enabled: !_saving,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter phone number';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_saving ? 'Saving...' : 'Save Changes'),
        ),
      ],
    );
  }
}
