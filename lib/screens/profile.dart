import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../widgets/profile_cards.dart';

// profile screen
// controls profile viewing, editing, & settings
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // control active profile section
  // 0 = About, 1 = RSVPs, 2 = Skills
  int _activeToggleIndex = 0;

  // control bottom nav selection
  // profile tab is active by default
  int _currentNavIndex = 4;

  // control current profile mode
  // view = display profile
  // edit = edit profile information
  // settings = account settings
  String _currentViewMode = 'view';

  // controllers for editable profile fields
  late TextEditingController _nameController;
  late TextEditingController _courseController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    // load initial profile info
    final user = DummyProfileData.mockUser;
    _nameController =
        TextEditingController(text: user.name);
    _courseController =
        TextEditingController(text: user.course);
    _locationController =
        TextEditingController(text: user.location);
    _bioController =
        TextEditingController(text: user.bio);
  }

  @override
  void dispose() {
    // dispose controllers to prevent memory leaks
    _nameController.dispose();
    _courseController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const scaffoldBg = Color(0xFF0F0E17);
    const accentYellow = Color(0xFFFFB800);
    const sidebarBg = Color(0xFF161422);
    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // responsive breakpoint:
            // wide screens use sidebar + multi-column layout
            // mobile uses single panel layout
            final isWideScreen =
                constraints.maxWidth > 768;
            // determine content to display
            Widget mainPanelContent;
            if (_currentViewMode == 'settings') {
              // display account settings
              mainPanelContent =
                  _buildSettingsPanel();
            } else if (_currentViewMode == 'edit') {
              // display profile editing
              mainPanelContent =
                  _buildEditPanel();
            } else {
              // display normal profile view
              mainPanelContent = _MasterProfilePanel(
                activeToggleIndex:
                    _activeToggleIndex,
                nameValue:
                    _nameController.text,
                courseValue:
                    _courseController.text,
                locationValue:
                    _locationController.text,
                bioValue:
                    _bioController.text,
                // update selected tab
                onToggleChanged: (val) =>
                    setState(() =>
                        _activeToggleIndex = val),
                // open edit
                onEditTriggered: () =>
                    setState(() =>
                        _currentViewMode = 'edit'),
                // open settings
                onSettingsTriggered: () =>
                    setState(() =>
                        _currentViewMode = 'settings'),
              );
            }

            if (isWideScreen) {
              // desktop/tablet layout
              return Row(
                children: [
                  // left nav sidebar
                  Container(
                    width: 72,
                    color: sidebarBg,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildSidebarIcon(
                          Icons.home_outlined,
                          0,
                        ),
                        _buildSidebarIcon(
                          Icons.work_outline,
                          1,
                        ),
                        const Spacer(),
                        // central create button
                        _buildSidebarCenterButton(
                          accentYellow,
                        ),
                        const Spacer(),
                        _buildSidebarIcon(
                          Icons.chat_bubble_outline,
                          3,
                        ),
                        _buildSidebarIcon(
                          Icons.person,
                          4,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),

                  // main profile content
                  SizedBox(
                    width: 420,
                    child: Container(
                      decoration:
                          const BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Color(0xFF1E1B2E),
                            width: 1,
                          ),
                        ),
                      ),
                      child:
                          mainPanelContent,
                    ),
                  ),

                  // dummy analytics section for wider screens
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Analytics View',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            // show only main profile on mobile
            return mainPanelContent;
          },
        ),
      ),

      // bottom nav on mobile
      bottomNavigationBar:
          MediaQuery.of(context).size.width <= 768
              ? BottomNavigationBar(
                  backgroundColor: scaffoldBg,
                  type:
                      BottomNavigationBarType.fixed,
                  selectedItemColor:
                      accentYellow,
                  unselectedItemColor:
                      Colors.grey,
                  currentIndex:
                      _currentNavIndex,
                  onTap: (index) =>
                      setState(() =>
                          _currentNavIndex = index),
                  selectedFontSize: 11,
                  unselectedFontSize: 11,
                  items: [
                    const BottomNavigationBarItem(
                      icon:
                          Icon(Icons.home_outlined),
                      label: 'Explore',
                    ),
                    const BottomNavigationBarItem(
                      icon:
                          Icon(Icons.work_outline),
                      label: 'Discover',
                    ),

                    BottomNavigationBarItem(
                      // center create button
                      icon: Container(
                        margin:
                            const EdgeInsets.only(
                                bottom: 4),
                        padding:
                            const EdgeInsets.all(6),
                        decoration:
                            BoxDecoration(
                          color:
                              accentYellow,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_box_outlined,
                          color:
                              Colors.black,
                          size: 20,
                        ),
                      ),
                      label: '',
                    ),
                    const BottomNavigationBarItem(
                      icon:
                          Icon(Icons.chat_bubble_outline),

                      label:
                          'Chats',
                    ),
                    const BottomNavigationBarItem(
                      icon:
                          Icon(Icons.person),
                      label:
                          'Profile',
                    ),
                  ],
                )
              : null,
    );
  }
  // build account settings screen
  // display profile-related settings actions
  Widget _buildSettingsPanel() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            16.0,
            24.0,
            24.0,
            16.0,
          ),
          child: Row(
            children: [
              // return to profile view
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () =>
                    setState(() =>
                        _currentViewMode = 'view'),
              ),

              const SizedBox(width: 8),

              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            children: const [
              // privacy settings option
              ActionMenuRow(
                icon:
                    Icons.lock_outline,
                iconColor:
                    Colors.grey,
                title:
                    'Account Privacy',
                subtitle:
                    'Manage visibility details',
              ),
              // notification settings option
              ActionMenuRow(
                icon:
                    Icons.notifications_none,
                iconColor:
                    Colors.grey,
                title:
                    'Push Alerts',
                subtitle:
                    'Toggle ping sounds rules',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // build profile editing screen
  // allow users to update profile info
  Widget _buildEditPanel() {
    const accentYellow =
        Color(0xFFFFB800);
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(
            16.0,
            24.0,
            24.0,
            16.0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // close edit mode
                  IconButton(
                    icon:
                        const Icon(
                      Icons.close,
                      color:
                          Colors.white,
                    ),
                    onPressed: () =>
                        setState(() =>
                            _currentViewMode =
                                'view'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize:
                          22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // save changes button
              TextButton(
                onPressed: () =>
                    setState(() =>
                        _currentViewMode =
                            'view'),
                child:
                    const Text(
                  'SAVE',
                  style:
                      TextStyle(
                    color:
                        accentYellow,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            children: [
              // editable profile fields
              EditableTextField(
                label:
                    'Full Name',
                controller:
                    _nameController,
              ),
              EditableTextField(
                label:
                    'Degree Course Title',
                controller:
                    _courseController,
              ),
              EditableTextField(
                label:
                    'Location Domain',
                controller:
                    _locationController,
              ),
              EditableTextField(
                label:
                    'Personal Summary Bio Statement',
                controller:
                    _bioController,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // build sidebar nav icons
  // highlights selected section
  Widget _buildSidebarIcon(
      IconData icon,
      int index,
  ) {
    return IconButton(
      icon: Icon(
        icon,
        color:
            _currentNavIndex == index
                ? const Color(0xFFFFB800)
                : Colors.grey,
        size:
            24,
      ),
      onPressed: () =>
          setState(() =>
              _currentNavIndex =
                  index),
    );
  }

  // build create button
  Widget _buildSidebarCenterButton(
      Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(8),
      decoration:
          BoxDecoration(
        color:
            color,
        borderRadius:
            BorderRadius.circular(8),
      ),
      child:
          const Icon(
        Icons.add_box_outlined,
        color:
            Colors.black,
        size:
            22,
      ),
    );
  }
}

// main profile content
// display user details, statistics, tabs, skills, RSVPs, & actions
class _MasterProfilePanel extends StatelessWidget {
  final int activeToggleIndex;
  final String nameValue;
  final String courseValue;
  final String locationValue;
  final String bioValue;
  final ValueChanged<int> onToggleChanged;
  final VoidCallback onEditTriggered;
  final VoidCallback onSettingsTriggered;

  const _MasterProfilePanel({
    required this.activeToggleIndex,
    required this.nameValue,
    required this.courseValue,
    required this.locationValue,
    required this.bioValue,
    required this.onToggleChanged,
    required this.onEditTriggered,
    required this.onSettingsTriggered,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg =
        Color(0xFF1E1B2E);
    const accentYellow =
        Color(0xFFFFB800);
    const signOutRedBg =
        Color(0xFF2D1418);
    const signOutRedText =
        Color(0xFFFF4D5E);
    // retrieve mock data
    final user =
        DummyProfileData.mockUser;
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(
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
                'Profile',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize:
                      26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon:
                        const Icon(
                      Icons.notifications_none,
                      color:
                          Colors.white,
                      size:
                          22,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon:
                        const Icon(
                      Icons.settings_outlined,
                      color:
                          Colors.white,
                      size:
                          22,
                    ),
                    onPressed:
                        onSettingsTriggered,
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context)
                .copyWith(scrollbars: false),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),
              children: [
                // main profile info card
                Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration:
                      BoxDecoration(
                    color:
                        cardBg,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // edit button avatar
                          Stack(
                            alignment:
                                Alignment.bottomRight,
                            children: [
                              Container(
                                width:
                                    80,
                                height:
                                    80,
                                decoration:
                                    BoxDecoration(
                                  color:
                                      user.avatarColor,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                alignment:
                                    Alignment.center,
                                child:
                                    Text(
                                  user.initials,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.black,
                                    fontSize:
                                        24,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Opens edit mode.
                              GestureDetector(
                                onTap:
                                    onEditTriggered,
                                child: Container(
                                  padding:
                                      const EdgeInsets.all(4),
                                  decoration:
                                      const BoxDecoration(
                                    color:
                                        Color(0xFF2C2A3A),
                                    shape:
                                        BoxShape.circle,
                                  ),
                                  child:
                                      const Icon(
                                    Icons.edit,
                                    color:
                                        Colors.white,
                                    size:
                                        12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nameValue,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        20,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  courseValue,
                                  style:
                                      TextStyle(
                                    color:
                                        Colors.white
                                            .withOpacity(0.7),
                                    fontSize:
                                        13,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                Text(
                                  '$locationValue • ${user.year}',
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.grey,
                                    fontSize:
                                        12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        child:
                            Divider(
                          color:
                              Colors.white10,
                          height:
                              1,
                        ),
                      ),

                      // Profile statistics.
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          MetricItem(
                            value:
                                '${user.metrics.rsvps}',
                            label:
                                'RSVPs',
                          ),
                          MetricItem(
                            value:
                                '${user.metrics.network}',
                            label:
                                'Network',
                          ),
                          MetricItem(
                            value:
                                '${user.metrics.skills}',
                            label:
                                'Skills',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // profile section selector
                Container(
                  padding:
                      const EdgeInsets.all(4),
                  decoration:
                      BoxDecoration(
                    color:
                        cardBg,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildTabToggle(
                        0,
                        'About',
                        accentYellow,
                      ),
                      _buildTabToggle(
                        1,
                        'RSVPs (${user.metrics.rsvps})',
                        accentYellow,
                      ),
                      _buildTabToggle(
                        2,
                        'Skills',
                        accentYellow,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                // about section
                if (activeToggleIndex == 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration:
                        BoxDecoration(
                      color:
                          cardBg,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bio',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    15,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap:
                                  onEditTriggered,
                              child:
                                  Icon(
                                Icons.edit_outlined,
                                color:
                                    Colors.white
                                        .withOpacity(0.6),
                                size:
                                    16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          bioValue,
                          style:
                              TextStyle(
                            color:
                                Colors.white
                                    .withOpacity(0.8),
                            fontSize:
                                13,
                            height:
                                1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // team searching skills
                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration:
                        BoxDecoration(
                      color:
                          cardBg,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Looking for teammates in',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing:
                              8,
                          runSpacing:
                              8,
                          children: const [
                            CustomChip(
                              label:
                                  'Backend Dev',
                              textColor:
                                  Color(0xFFB080FF),
                              borderColor:
                                  Color(0xFF6236FF),
                            ),
                            CustomChip(
                              label:
                                  'Product Manager',
                              textColor:
                                  Color(0xFF50B3FF),
                              borderColor:
                                  Color(0xFF0091FF),
                            ),
                            CustomChip(
                              label:
                                  'Designer',
                              textColor:
                                  Color(0xFF33CC99),
                              borderColor:
                                  Color(0xFF00B27A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const ActionMenuRow(
                    icon:
                        Icons.bookmark_outline,
                    iconColor:
                        accentYellow,
                    title:
                        'My RSVPs',
                    subtitle:
                        '3 events & opportunities',
                  ),

                  const ActionMenuRow(
                    icon:
                        Icons.people_outline,
                    iconColor:
                        Color(0xFF0091FF),
                    title:
                        'Find Teammates',
                    subtitle:
                        'Skill-based matching',
                  ),

                  const ActionMenuRow(
                    icon:
                        Icons.star_border_outlined,
                    iconColor:
                        Color(0xFFFFB800),
                    title:
                        'Saved Opportunities',
                    subtitle:
                        'Bookmarked posts',
                  ),
                ],

                // RSVP section
                if (activeToggleIndex == 1) ...[
                  ...DummyProfileData.mockRsvps.map(
                    (event) {
                      return RsvpEventCard(
                        title:
                            event.title,
                        dateText:
                            event.dateText,
                      );
                    },
                  ).toList(),
                ],

                // skills section
                if (activeToggleIndex == 2) ...[
                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration:
                        BoxDecoration(
                      color:
                          cardBg,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Skills',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Wrap(
                          spacing:
                              8,
                          runSpacing:
                              8,
                          children: [
                            ...DummyProfileData.mockSkills
                                .map((skill) {
                              return CustomChip(
                                label:
                                    skill['name'],
                                textColor:
                                    (skill['color'] as Color)
                                        .withOpacity(0.8),
                                borderColor:
                                    skill['color'],
                              );
                            }),
                            DottedAddChip(
                              label:
                                  'Add skill',
                              onTap:
                                  () {},
                            ),
                          ],
                        ),

                        const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          child:
                              Divider(
                            color:
                                Colors.white10,
                            height:
                                1,
                          ),
                        ),

                        const Text(
                          'Seeking (for teamwork)',
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),
                        Wrap(
                          spacing:
                              8,
                          runSpacing:
                              8,
                          children:
                              DummyProfileData
                                  .mockSeekingTags
                                  .map((tag) {
                            return CustomChip(
                              label:
                                  tag,
                              textColor:
                                  Colors.grey,
                              borderColor:
                                  Colors.white10,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                // sign out button
                InkWell(
                  onTap:
                      () {},
                  borderRadius:
                      BorderRadius.circular(16),
                  child: Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration:
                        BoxDecoration(
                      color:
                          signOutRedBg,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(8),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white
                                    .withOpacity(0.02),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child:
                              const Icon(
                            Icons.logout_outlined,
                            color:
                                signOutRedText,
                            size:
                                20,
                          ),
                        ),

                        const SizedBox(width: 16),

                        const Text(
                          'Sign Out',
                          style:
                              TextStyle(
                            color:
                                signOutRedText,
                            fontSize:
                                15,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // build About/ RSVP/Skills tab buttons
  Widget _buildTabToggle(
      int index,
      String title,
      Color activeColor,
  ) {
    final isSelected =
        activeToggleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            onToggleChanged(index),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration:
              BoxDecoration(
            color:
                isSelected
                    ? activeColor
                    : Colors.transparent,
            borderRadius:
                BorderRadius.circular(10),
          ),
          alignment:
              Alignment.center,
          child:
              Text(
            title,
            style:
                TextStyle(
              color:
                  isSelected
                      ? Colors.black
                      : Colors.grey,
              fontSize:
                  13,
              fontWeight:
                  isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

