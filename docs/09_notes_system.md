# ICHITO -- Notes System

**Document**: 09 of 14
**Covers**: Three note types (Normal, Church, Chama), note list screen, type-specific editors, Bible verse tagging, Chama contribution tracking, search and filter, auto-save behavior

---

## 1. Notes Overview

ICHITO includes a personal note-taking system designed for the tailor's day-to-day needs outside of order management. Three distinct note types serve different purposes:

| Type | Purpose | Key Fields |
|------|---------|------------|
| **Normal** | General notes, reminders, business ideas | Title, content |
| **Church** | Sermon notes and Bible study records | Title, content, speaker, Bible verses |
| **Chama** | Group savings (chama) meeting records | Title, content, meeting date, members, contributions, recipient |

---

## 2. Notes List Screen

### 2.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]  Notes                         [+ New Note] │
├─────────────────────────────────────────────────────┤
│  [SearchIcon] Search notes...                        │
│                                                      │
│  [All]  [Normal]  [Church]  [Chama]                 │
│  (filter tabs)                                       │
│                                                      │
│  Sort: [Newest v] [Oldest] [Title A-Z]              │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │  [NoteIcon] Shopping List                       ││
│  │  Need to buy: buttons, thread, zipper...        ││
│  │  Normal Note                                    ││
│  │  2 hours ago                                    ││
│  ├──────────────────────────────────────────────────┤│
│  │  [ChurchIcon] Sunday Service 13/07              ││
│  │  Topic: Walking by Faith                        ││
│  │  Speaker: Pastor David                          ││
│  │  [VerseChip: Heb 11:1] [VerseChip: Rom 8:28]   ││
│  │  Yesterday                                      ││
│  ├──────────────────────────────────────────────────┤│
│  │  [ChamaIcon] July Meeting                       ││
│  │  Members: 8  |  Collected: KES 24,000           ││
│  │  Recipient: Jane Muthoni                        ││
│  │  3 days ago                                     ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Total: 32 Notes                                     │
│  80dp bottom padding                                 │
├─────────────────────────────────────────────────────┤
│              [Radial Menu FAB]                       │
└─────────────────────────────────────────────────────┘
```

### 2.2 New Note Type Selector

Tapping "+ New Note" opens a bottom sheet:

```
┌─────────────────────────────────────────────────────┐
│  What type of note?                                  │
├─────────────────────────────────────────────────────┤
│  [NoteIcon]     Normal Note                         │
│                 General notes and reminders          │
│  ─────────────────────────────────────────────────── │
│  [ChurchIcon]   Church Note                         │
│                 Sermon notes and Bible study          │
│  ─────────────────────────────────────────────────── │
│  [ChamaIcon]    Chama Note                          │
│                 Group savings meeting records         │
└─────────────────────────────────────────────────────┘
```

Icons:
- Normal: `Icons.note_outlined`
- Church: `Icons.church_outlined`
- Chama: `Icons.groups_outlined`

### 2.3 Note Card Widget

```dart
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showQuickActions(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: theme.cornerRadius,
          boxShadow: theme.cardShadow != null ? [theme.cardShadow!] : null,
          border: Border.all(color: theme.borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + title
            Row(
              children: [
                Icon(_getNoteIcon(), size: 20, color: _getNoteColor(theme)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Content preview
            Text(
              note.content.isEmpty ? '(No content)' : note.content,
              style: TextStyle(fontSize: 13, color: theme.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Type-specific info
            if (note.isChurchNote) ...[
              const SizedBox(height: 8),
              if (note.speaker != null)
                Text(
                  'Speaker: ${note.speaker}',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              if (note.bibleVerses != null && note.bibleVerses!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.bibleVerses!.map((verse) =>
                    VerseChip(verse: verse),
                  ).toList(),
                ),
              ],
            ],
            if (note.isChamaNote) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Members: ${note.members?.length ?? 0}',
                    style: TextStyle(fontSize: 12, color: theme.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Collected: ${language.formatCurrency(note.totalCollected ?? 0)}',
                    style: TextStyle(fontSize: 12, color: theme.accentColor),
                  ),
                ],
              ),
              if (note.recipient != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Recipient: ${note.recipient}',
                  style: TextStyle(fontSize: 12, color: theme.textSecondary),
                ),
              ],
            ],
            // Timestamp and type badge
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getNoteColor(theme).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getNoteTypeName(),
                    style: TextStyle(fontSize: 10, color: _getNoteColor(theme)),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimeAgo(note.updatedAt),
                  style: TextStyle(fontSize: 11, color: theme.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getNoteIcon() {
    switch (note.type) {
      case 'church': return Icons.church_outlined;
      case 'chama': return Icons.groups_outlined;
      default: return Icons.note_outlined;
    }
  }
  
  Color _getNoteColor(ThemeProvider theme) {
    switch (note.type) {
      case 'church': return const Color(0xFF9C27B0); // Purple
      case 'chama': return const Color(0xFF4CAF50); // Green
      default: return theme.accentColor;
    }
  }
  
  String _getNoteTypeName() {
    switch (note.type) {
      case 'church': return 'Church';
      case 'chama': return 'Chama';
      default: return 'Normal';
    }
  }
}
```

---

## 3. Normal Note Editor

### 3.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Close]  Normal Note              [Delete]  [Save] │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Title                                               │
│  ┌──────────────────────────────────────────────────┐│
│  │  Shopping List                                  ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Content                                             │
│  ┌──────────────────────────────────────────────────┐│
│  │  Need to buy:                                   ││
│  │  - Buttons (gold, 12mm)                         ││
│  │  - Thread (white, black)                        ││
│  │  - Zipper (invisible, 20cm)                     ││
│  │  - Elastic (2cm width)                          ││
│  │                                                 ││
│  │  Check Eastleigh shops for better prices.       ││
│  │                                                 ││
│  │                                                 ││
│  │                                                 ││
│  │                                                 ││
│  │                                                 ││
│  │                                                 ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Last edited: 17/07/2026 14:30                       │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 3.2 Behavior

- Title auto-generates as "Note - {DD/MM/YYYY HH:mm}" if left empty
- Content area is a large multi-line text field that expands to fill available space
- Auto-save triggers after 3 seconds of inactivity (configurable in Settings)
- Manual save via app bar button
- Close triggers unsaved changes guard (see Navigation doc)
- Delete available for existing notes (confirmation dialog)

### 3.3 Auto-Save Implementation

```dart
Timer? _autoSaveTimer;

void _onContentChanged(String value) {
  _autoSaveTimer?.cancel();
  _hasUnsavedChanges = true;
  
  if (_autoSaveEnabled) {
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      _saveNote();
      _showAutoSaveIndicator(); // Brief "Saved" text flash
    });
  }
}

void _showAutoSaveIndicator() {
  setState(() => _showingSaved = true);
  Future.delayed(const Duration(seconds: 1), () {
    if (mounted) setState(() => _showingSaved = false);
  });
}
```

---

## 4. Church Note Editor

### 4.1 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Close]  Church Note              [Delete]  [Save] │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Title *                                             │
│  ┌──────────────────────────────────────────────────┐│
│  │  Sunday Service 13/07                           ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Speaker                                             │
│  ┌──────────────────────────────────────────────────┐│
│  │  [PersonIcon]  Pastor David Mwangi              ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Bible Verses                                        │
│  ┌──────────────────────────────────────────────────┐│
│  │  [VerseChip: Hebrews 11:1] [x]                  ││
│  │  [VerseChip: Romans 8:28]  [x]                  ││
│  │  [VerseChip: Psalm 23:1]   [x]                  ││
│  │  [+ Add Verse]                                  ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Sermon Notes                                        │
│  ┌──────────────────────────────────────────────────┐│
│  │  Walking by Faith                               ││
│  │                                                 ││
│  │  Key Points:                                    ││
│  │  1. Faith is the evidence of things not seen    ││
│  │  2. Trust in God's plan even when you can't     ││
│  │     see the full picture                        ││
│  │  3. All things work together for good           ││
│  │                                                 ││
│  │  Application:                                   ││
│  │  - Pray more, worry less                        ││
│  │  - Trust the process in business                ││
│  │                                                 ││
│  │                                                 ││
│  │                                                 ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Last edited: 13/07/2026 11:45                       │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 4.2 Bible Verse Input

Adding a verse:
1. Tap "+ Add Verse"
2. A text field appears with a hint: "e.g., John 3:16 or Genesis 1:1-3"
3. User types the verse reference and taps Enter/Done
4. The verse reference is added as a chip
5. Chips are removable with [x]
6. No limit on number of verses

### 4.3 Verse Chip Widget

```dart
class VerseChip extends StatelessWidget {
  final String verse;
  final bool removable;
  final VoidCallback? onRemove;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final chipColor = const Color(0xFF9C27B0); // Purple for church
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.book_outlined, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            verse,
            style: TextStyle(
              fontSize: 11,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (removable) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 14, color: chipColor),
            ),
          ],
        ],
      ),
    );
  }
}
```

### 4.4 Church Note Validation

| Field | Required | Constraints |
|-------|----------|-------------|
| Title | Yes | Auto-generates if empty: "Church Note - {date}" |
| Speaker | No | Max 100 characters |
| Bible Verses | No | Each verse max 50 characters, unlimited count |
| Content | No | Unlimited text |

---

## 5. Chama Note Editor

### 5.1 Purpose

A chama (Swahili for group) is a group savings scheme common in East Africa. Members contribute a fixed amount regularly, and one member receives the full collection each round. The chama note tracks:
- Meeting date
- Members present
- Each member's contribution amount
- Total collected vs. expected
- Who receives the collection this round

### 5.2 Layout

```
┌─────────────────────────────────────────────────────┐
│  [Close]  Chama Note               [Delete]  [Save] │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Title *                                             │
│  ┌──────────────────────────────────────────────────┐│
│  │  July Meeting                                   ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Meeting Date *                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │  15/07/2026                      [CalendarIcon] ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Recipient (who receives this round)                │
│  ┌──────────────────────────────────────────────────┐│
│  │  [PersonIcon]  Jane Muthoni                     ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Expected Contribution per Member                    │
│  ┌──────────────────────────────────────────────────┐│
│  │  [WalletIcon]  3,000                    KES     ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  ── Members & Contributions ──────────────────────── │
│                                                      │
│  ┌──────────────────────────────────────────────────┐│
│  │  [#] Name              Amount     Status        ││
│  │  ─────────────────────────────────────────────── ││
│  │  1.  Jane Muthoni      [  3,000] [StatusDot:Green]││
│  │  2.  Mary Johnson      [  3,000] [StatusDot:Green]││
│  │  3.  Grace Akinyi      [  3,000] [StatusDot:Green]││
│  │  4.  Sarah Wanjiku     [  3,000] [StatusDot:Green]││
│  │  5.  Faith Njeri       [  2,500] [StatusDot:Yellow]││
│  │  6.  Agnes Nyambura    [  3,000] [StatusDot:Green]││
│  │  7.  Rose Atieno       [  3,000] [StatusDot:Green]││
│  │  8.  Joy Mwende        [    0  ] [StatusDot:Red]││
│  │  ─────────────────────────────────────────────── ││
│  │  [+ Add Member]                                 ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  ── Summary ─────────────────────────────────────── │
│  ┌──────────────────────────────────────────────────┐│
│  │  Total Expected:    KES 24,000                  ││
│  │  Total Collected:   KES 21,500                  ││
│  │  Shortfall:         KES  2,500                  ││
│  │  Members Paid:      6 of 8                      ││
│  │  Fully Paid:        6  |  Partial: 1  |  None: 1││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Notes                                               │
│  ┌──────────────────────────────────────────────────┐│
│  │  Joy was absent. Faith sent partial via M-Pesa. ││
│  └──────────────────────────────────────────────────┘│
│                                                      │
│  Last edited: 15/07/2026 20:30                       │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 5.3 Contribution Row Widget

```dart
class ContributionRow extends StatelessWidget {
  final int index;
  final String memberName;
  final double amount;
  final double expectedAmount;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onRemove;
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Index
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}.',
              style: TextStyle(fontSize: 13, color: theme.textSecondary),
            ),
          ),
          // Member name
          Expanded(
            flex: 3,
            child: Text(
              memberName,
              style: TextStyle(fontSize: 13, color: theme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Amount input
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: amount > 0 ? amount.toStringAsFixed(0) : '',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, color: theme.textPrimary),
              decoration: InputDecoration(
                hintText: '0',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value) ?? 0;
                onAmountChanged(parsed);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Status dot
          StatusDot(
            status: amount >= expectedAmount
              ? 'completed'
              : amount > 0
                ? 'in_progress'
                : 'pending',
          ),
          const SizedBox(width: 4),
          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: theme.textSecondary),
          ),
        ],
      ),
    );
  }
}
```

### 5.4 Add Member Flow

1. Tap "+ Add Member"
2. A text field appears inline at the bottom of the member list
3. User types member name and taps Enter/Done
4. Member is added to the list with 0 contribution
5. The member name is saved in the `members` list
6. Previous chama notes' member names are suggested as auto-complete options

### 5.5 Chama Summary Calculations

```dart
// Auto-calculated from contributions map
double get totalCollected {
  if (contributions == null) return 0;
  return contributions!.values.fold(0, (sum, amount) => sum + amount);
}

double get expectedTotal {
  if (members == null || _expectedPerMember == 0) return 0;
  return members!.length * _expectedPerMember;
}

double get shortfall {
  final diff = expectedTotal - totalCollected;
  return diff > 0 ? diff : 0;
}

int get membersFullyPaid {
  if (contributions == null) return 0;
  return contributions!.values.where((amount) => amount >= _expectedPerMember).length;
}

int get membersPartiallyPaid {
  if (contributions == null) return 0;
  return contributions!.values.where((amount) => amount > 0 && amount < _expectedPerMember).length;
}

int get membersUnpaid {
  if (members == null || contributions == null) return 0;
  return members!.where((name) => (contributions![name] ?? 0) <= 0).length;
}
```

### 5.6 Chama Note Validation

| Field | Required | Constraints |
|-------|----------|-------------|
| Title | Yes | Auto-generates if empty: "Chama - {date}" |
| Meeting Date | Yes | Opens date picker |
| Recipient | No | Max 100 characters |
| Expected per Member | No | Must be > 0 if provided |
| Members | At least 1 | Each name max 50 characters |
| Contributions | Auto | Each value >= 0 |
| Notes | No | Unlimited text |

---

## 6. Note Search

Search queries match against:
- `title` (LIKE with wildcards)
- `content` (LIKE with wildcards)
- `speaker` (for church notes)
- `bible_verses` (JSON text search for verse references)
- `members` (JSON text search for member names)

```sql
SELECT * FROM notes
WHERE (title LIKE '%query%' OR content LIKE '%query%'
       OR speaker LIKE '%query%'
       OR bible_verses LIKE '%query%'
       OR members LIKE '%query%')
  AND (type = ? OR ? IS NULL)
ORDER BY updated_at DESC;
```

---

## 7. Note Deletion

- No dependencies -- notes can always be deleted
- Confirmation dialog: "Delete '{note.title}'? This cannot be undone."
- Immediate deletion from database

---

## 8. Note Sort Options

| Option | Query |
|--------|-------|
| Newest (default) | `ORDER BY updated_at DESC` |
| Oldest | `ORDER BY created_at ASC` |
| Title A-Z | `ORDER BY title ASC` |
| Title Z-A | `ORDER BY title DESC` |

---

## 9. Long Press Quick Actions

| Action | Icon | Behavior |
|--------|------|----------|
| Edit | `Icons.edit_outlined` | Open appropriate editor |
| Delete | `Icons.delete_outlined` | Confirmation -> delete |
| Duplicate | `Icons.copy_outlined` | Create copy with "(Copy)" suffix |
| Share | `Icons.share_outlined` | Share note content as text |

---

## 10. Note Data Serialization

### 10.1 JSON Storage for Complex Fields

Since SQLite stores these as TEXT, the Note model handles serialization:

```dart
class Note {
  // Bible verses stored as JSON array: '["Hebrews 11:1", "Romans 8:28"]'
  static List<String>? _parseVerses(String? json) {
    if (json == null || json.isEmpty) return null;
    return List<String>.from(jsonDecode(json));
  }
  
  static String? _encodeVerses(List<String>? verses) {
    if (verses == null || verses.isEmpty) return null;
    return jsonEncode(verses);
  }
  
  // Members stored as JSON array: '["Jane", "Mary", "Grace"]'
  static List<String>? _parseMembers(String? json) {
    if (json == null || json.isEmpty) return null;
    return List<String>.from(jsonDecode(json));
  }
  
  // Contributions stored as JSON map: '{"Jane": 3000, "Mary": 3000}'
  static Map<String, double>? _parseContributions(String? json) {
    if (json == null || json.isEmpty) return null;
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'speaker': speaker,
      'bible_verses': _encodeVerses(bibleVerses),
      'meeting_date': meetingDate?.toIso8601String(),
      'members': _parseMembers != null ? jsonEncode(members) : null,
      'contributions': contributions != null ? jsonEncode(contributions) : null,
      'total_collected': totalCollected,
      'expected_total': expectedTotal,
      'recipient': recipient,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

---

*This is Document 09 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
