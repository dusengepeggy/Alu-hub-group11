import 'package:flutter/material.dart';
import '../models/chats_data.dart';
import '../widgets/items.dart';

// screen controller for layout switches btwn mobile & desktop
class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  String _searchQuery = '';
  String? _selectedChatId;
  int _currentNavIndex = 3; // 'Chats' tab active by default

  @override
  Widget build(BuildContext context) {
    const scaffoldBg = Color(0xFF0F0E17);
    const accentYellow = Color(0xFFFFB800);
    const sidebarBg = Color(0xFF161422);

    // search query
    final filteredMessages = DummyChatData.allMessages.where((msg) {
      return msg.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          msg.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // calculate unread message count
    final totalUnread =
        DummyChatData.allMessages.where((m) => !m.isRead).length;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // screen width breakpoint
            final isWideScreen = constraints.maxWidth > 768;

            // shared master conversation list instance
            Widget masterListPanel = _MasterListPanel(
              searchQuery: _searchQuery,
              filteredMessages: filteredMessages,
              selectedChatId: _selectedChatId,
              totalUnread: totalUnread,
              onSearchChanged: (val) =>
                  setState(() => _searchQuery = val),
              onChatSelected: (id) =>
                  setState(() => _selectedChatId = id),
            );

            if (isWideScreen) {
              final activeChat = DummyChatData.allMessages.firstWhere(
                (m) => m.id == _selectedChatId,
                orElse: () => DummyChatData.allMessages.first,
              );

              return Row(
                children: [
                  // left sidebar for desktop
                  Container(
                    width: 72,
                    color: sidebarBg,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildSidebarIcon(Icons.home_outlined, 0),
                        _buildSidebarIcon(Icons.work_outline, 1),
                        const Spacer(),
                        _buildSidebarCenterButton(accentYellow),
                        const Spacer(),
                        _buildSidebarIcon(Icons.chat_bubble, 3),
                        _buildSidebarIcon(Icons.person_outline, 4),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // middle conversations list nav drawer
                  SizedBox(
                    width: 360,
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0xFF1E1B2E),
                            width: 1,
                          ),
                        ),
                      ),
                      child: masterListPanel,
                    ),
                  ),

                  // right side expanded detail pane
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: _avatarColorForTitle(activeChat.title),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            activeChat.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last Active: ${activeChat.timeAgo}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // fallback mobile view
            return masterListPanel;
          },
        ),
      ),

      // display bottom nav utility bars for mobile
      bottomNavigationBar: MediaQuery.of(context).size.width <= 768
          ? BottomNavigationBar(
              backgroundColor: scaffoldBg,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: accentYellow,
              unselectedItemColor: Colors.grey,
              currentIndex: _currentNavIndex,
              onTap: (index) =>
                  setState(() => _currentNavIndex = index),
              selectedFontSize: 11,
              unselectedFontSize: 11,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  label: 'Explore',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.work_outline),
                  label: 'Discover',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_box_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble),
                  label: 'Chats',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildSidebarIcon(IconData icon, int index) {
    final isSelected = _currentNavIndex == index;

    return IconButton(
      icon: Icon(
        icon,
        color: isSelected
            ? const Color(0xFFFFB800)
            : Colors.grey,
        size: 24,
      ),
      onPressed: () =>
          setState(() => _currentNavIndex = index),
    );
  }

  Widget _buildSidebarCenterButton(Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.add_box_outlined,
        color: Colors.black,
        size: 22,
      ),
    );
  }

  Color _avatarColorForTitle(String title) {
    if (title.contains('Pitch')) {
      return const Color(0xFF6236FF);
    }

    if (title.contains('Kwame')) {
      return const Color(0xFF0091FF);
    }

    if (title.contains('Hackathon')) {
      return const Color(0xFF00B27A);
    }

    return const Color(0xFFFF2D55);
  }
}

/// scrollable view displaying chat threads & group feeds
class _MasterListPanel extends StatelessWidget {
  final String searchQuery;
  final List<ChatMessage> filteredMessages;
  final String? selectedChatId;
  final int totalUnread;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onChatSelected;

  const _MasterListPanel({
    required this.searchQuery,
    required this.filteredMessages,
    required this.selectedChatId,
    required this.totalUnread,
    required this.onSearchChanged,
    required this.onChatSelected,
  });

  @override
  Widget build(BuildContext context) {
    const searchBarBg = Color(0xFF1E1B2E);
    const cardBg = Color(0xFF1E1B2E);
    const accentYellow = Color(0xFFFFB800);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // app title header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            24.0,
            24.0,
            24.0,
            16.0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2514),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        accentYellow.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '$totalUnread ',
                      style: const TextStyle(
                        color: accentYellow,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      'new',
                      style: TextStyle(
                        color: accentYellow,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // data sorting search field
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 8.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: searchBarBg,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText:
                    'Search conversations...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),

        // scrollable area for inputs definitions
        Expanded(
          child: ListView(
            padding:
                const EdgeInsets.symmetric(
              vertical: 16.0,
            ),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Active groups',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // horizontal groups view
              SizedBox(
                height: 85,
                child: ListView.builder(
                  scrollDirection:
                      Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  itemCount:
                      DummyChatData.activeGroups.length,
                  itemBuilder:
                      (context, index) {
                    final group =
                        DummyChatData.activeGroups[index];

                    return ActiveGroupItem(
                      initials:
                          group.initials,
                      name: group.name,
                      color:
                          group.avatarColor,
                      badgeCount:
                          group.badgeCount,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'All messages',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ),

              // vertical thread messages cards feed
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                ),
                child: filteredMessages.isEmpty
                    ? const Padding(
                        padding:
                            EdgeInsets.only(top: 32.0),
                        child: Center(
                          child: Text(
                            'No messages found',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: filteredMessages.map(
                          (msg) {
                            final isSelected =
                                selectedChatId == msg.id;

                            return MessageCard(
                              initials:
                                  msg.initials,
                              avatarColor:
                                  msg.avatarColor,
                              title:
                                  msg.title,
                              subtitle:
                                  msg.lastMessage,
                              time:
                                  msg.timeAgo,
                              tagText:
                                  msg.groupTag,
                              badgeCount:
                                  msg.badgeCount,
                              isRead:
                                  msg.isRead,
                              isSelected:
                                  isSelected,
                              cardBg:
                                  cardBg,
                              accentYellow:
                                  accentYellow,
                              onTap: () =>
                                  onChatSelected(
                                msg.id,
                              ),
                            );
                          },
                        ).toList(),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

