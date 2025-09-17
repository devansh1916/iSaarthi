import React, { useState } from 'react';
import { 
  Home, 
  Filter, 
  Building, 
  Target, 
  BarChart3, 
  Settings, 
  Menu, 
  X,
  Bell,
  User,
  Search,
  LogOut
} from 'lucide-react';

const Navigation = ({ currentPage, onPageChange }) => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const [notifications, setNotifications] = useState(5);
  const [showNotifications, setShowNotifications] = useState(false);
  const [showSettings, setShowSettings] = useState(false);

  const navigationItems = [
    {
      id: 'dashboard',
      name: 'Dashboard',
      icon: Home,
      description: 'Overview of all issues'
    },
    {
      id: 'issues',
      name: 'Issue Management',
      icon: Filter,
      description: 'Filter and sort issues'
    },
    {
      id: 'assignment',
      name: 'Department Assignment',
      icon: Building,
      description: 'Route issues to departments'
    },
    {
      id: 'priority',
      name: 'Priority Management',
      icon: Target,
      description: 'Smart prioritization'
    },
    {
      id: 'analytics',
      name: 'Analytics',
      icon: BarChart3,
      description: 'Reports and insights'
    }
  ];

  const handlePageChange = (pageId) => {
    onPageChange(pageId);
    setIsMobileMenuOpen(false);
  };

  const handleNotificationClick = () => {
    setShowNotifications(!showNotifications);
    setShowSettings(false);
  };

  const handleSettingsClick = () => {
    setShowSettings(!showSettings);
    setShowNotifications(false);
  };

  const handleNotificationAction = (action) => {
    console.log(`Notification action: ${action}`);
    // Implement notification actions here
  };

  const handleSettingsAction = (action) => {
    console.log(`Settings action: ${action}`);
    // Implement settings actions here
  };

  return (
    <>
      {/* Mobile menu button */}
      <div className="lg:hidden fixed top-4 left-4 z-50">
        <button
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          className="p-2 bg-white rounded-lg shadow-md border border-gray-200"
        >
          {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile overlay */}
      {isMobileMenuOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* Sidebar */}
      <div 
        className={`
          fixed top-0 left-0 h-full w-64 shadow-lg z-30 transform transition-transform duration-300 ease-in-out
          ${isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'}
          lg:translate-x-0
        `}
        style={{ 
          backgroundColor: '#55AD9B',
          borderRight: '1px solid #4a9a8a'
        }}
      >
        {/* Header */}
        <div 
          className="p-6 border-b"
          style={{ borderBottomColor: '#6bb8a9' }}
        >
          <div className="flex items-center space-x-3">
            <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center shadow-md">
              <Building className="w-5 h-5" style={{ color: '#4a9a8a' }} />
            </div>
            <div>
              <h1 className="text-lg font-bold text-white">Civic Portal</h1>
              <p className="text-xs" style={{ color: '#7cc4b7' }}>Issue Management System</p>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-2">
          {navigationItems.map((item) => {
            const Icon = item.icon;
            const isActive = currentPage === item.id;
            
            return (
              <button
                key={item.id}
                onClick={() => handlePageChange(item.id)}
                className={`
                  w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-left transition-colors group
                  ${isActive 
                    ? 'bg-white border shadow-md' 
                    : 'bg-white'
                  }
                `}
                style={isActive ? {
                  color: '#55AD9B',
                  borderColor: '#55AD9B'
                } : {
                  color: '#55AD9B',
                  backgroundColor: 'white'
                }}
                onMouseEnter={(e) => {
                  if (!isActive) {
                    e.target.style.backgroundColor = 'white';
                    e.target.style.color = '#55AD9B';
                  }
                }}
                onMouseLeave={(e) => {
                  if (!isActive) {
                    e.target.style.backgroundColor = 'white';
                    e.target.style.color = '#55AD9B';
                  }
                }}
              >
                <Icon 
                  className="w-5 h-5" 
                  style={{ color: '#55AD9B' }}
                />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{item.name}</p>
                  <p 
                    className="text-xs truncate"
                    style={{ color: '#55AD9B' }}
                  >
                    {item.description}
                  </p>
                </div>
              </button>
            );
          })}
        </nav>

        {/* User section */}
        <div 
          className="p-4 border-t"
          style={{ borderTopColor: '#6bb8a9' }}
        >
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-8 h-8 bg-white rounded-full flex items-center justify-center">
              <User className="w-4 h-4" style={{ color: '#4a9a8a' }} />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-white truncate">Admin User</p>
              <p className="text-xs" style={{ color: '#7cc4b7' }}>admin@city.gov</p>
            </div>
          </div>
          
          <div className="flex space-x-2">
            <button 
              onClick={handleSettingsClick}
              className="flex-1 flex items-center justify-center space-x-2 px-3 py-2 bg-white rounded-lg transition-colors"
              style={{ color: '#4a9a8a' }}
              onMouseEnter={(e) => {
                e.target.style.backgroundColor = '#f0f9f7';
              }}
              onMouseLeave={(e) => {
                e.target.style.backgroundColor = 'white';
              }}
            >
              <Settings className="w-4 h-4" />
              <span className="text-xs">Settings</span>
            </button>
            <button className="flex-1 flex items-center justify-center space-x-2 px-3 py-2 !bg-red-400 !text-white rounded-lg hover:!bg-red-500 transition-colors">
              <LogOut className="w-4 h-4" />
              <span className="text-xs">Logout</span>
            </button>
          </div>
        </div>
      </div>

      {/* Top bar */}
      <div className="lg:ml-64 bg-gradient-to-r from-white to-green-50 border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <h2 className="text-xl font-semibold text-gray-900">
              {navigationItems.find(item => item.id === currentPage)?.name || 'Dashboard'}
            </h2>
            <span className="text-sm text-gray-500">
              {navigationItems.find(item => item.id === currentPage)?.description}
            </span>
          </div>
          
          <div className="flex items-center space-x-4">
            {/* Search */}
            <div className="hidden md:block relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search issues..."
                className="pl-10 pr-4 py-2 border border-gray-300 text-gray-900 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent w-64 placeholder-gray-500"
              />
            </div>

            {/* Notifications */}
            <div className="relative">
              <button 
                onClick={handleNotificationClick}
                className="relative p-2 text-gray-400 hover:text-green-600 transition-colors"
              >
                <Bell className="w-5 h-5" />
                {notifications > 0 && (
                  <span className="absolute -top-1 -right-1 w-5 h-5 bg-green-500 text-white text-xs rounded-full flex items-center justify-center">
                    {notifications}
                  </span>
                )}
              </button>
              
              {/* Notifications Dropdown */}
              {showNotifications && (
                <div className="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-lg border border-gray-200 z-50">
                  <div className="p-4 border-b border-gray-200">
                    <h3 className="text-lg font-semibold text-gray-900">Notifications</h3>
                  </div>
                  <div className="max-h-64 overflow-y-auto">
                    <div className="p-4 hover:bg-gray-50 border-b border-gray-100">
                      <div className="flex items-start space-x-3">
                        <div className="w-2 h-2 bg-green-500 rounded-full mt-2"></div>
                        <div className="flex-1">
                          <p className="text-sm font-medium text-gray-900">New issue reported</p>
                          <p className="text-xs text-gray-500">Pothole on Main Street needs attention</p>
                          <p className="text-xs text-gray-400 mt-1">2 minutes ago</p>
                        </div>
                      </div>
                    </div>
                    <div className="p-4 hover:bg-gray-50 border-b border-gray-100">
                      <div className="flex items-start space-x-3">
                        <div className="w-2 h-2 bg-yellow-500 rounded-full mt-2"></div>
                        <div className="flex-1">
                          <p className="text-sm font-medium text-gray-900">Issue status updated</p>
                          <p className="text-xs text-gray-500">Street light repair completed</p>
                          <p className="text-xs text-gray-400 mt-1">1 hour ago</p>
                        </div>
                      </div>
                    </div>
                    <div className="p-4 hover:bg-gray-50 border-b border-gray-100">
                      <div className="flex items-start space-x-3">
                        <div className="w-2 h-2 bg-blue-500 rounded-full mt-2"></div>
                        <div className="flex-1">
                          <p className="text-sm font-medium text-gray-900">Department assignment</p>
                          <p className="text-xs text-gray-500">Sewer backup assigned to Public Works</p>
                          <p className="text-xs text-gray-400 mt-1">3 hours ago</p>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div className="p-4 border-t border-gray-200">
                    <button 
                      onClick={() => handleNotificationAction('markAllRead')}
                      className="w-full text-sm text-green-600 hover:text-green-700 font-medium"
                    >
                      Mark all as read
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Settings Dropdown */}
            {showSettings && (
              <div className="absolute right-0 mt-2 w-64 bg-white rounded-lg shadow-lg border border-gray-200 z-50">
                <div className="p-4 border-b border-gray-200">
                  <h3 className="text-lg font-semibold text-gray-900">Settings</h3>
                </div>
                <div className="py-2">
                  <button 
                    onClick={() => handleSettingsAction('profile')}
                    className="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-green-50 hover:text-green-700"
                  >
                    Profile Settings
                  </button>
                  <button 
                    onClick={() => handleSettingsAction('notifications')}
                    className="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-green-50 hover:text-green-700"
                  >
                    Notification Preferences
                  </button>
                  <button 
                    onClick={() => handleSettingsAction('theme')}
                    className="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-green-50 hover:text-green-700"
                  >
                    Theme Settings
                  </button>
                  <button 
                    onClick={() => handleSettingsAction('privacy')}
                    className="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-green-50 hover:text-green-700"
                  >
                    Privacy & Security
                  </button>
                  <div className="border-t border-gray-200 my-2"></div>
                  <button 
                    onClick={() => handleSettingsAction('help')}
                    className="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-green-50 hover:text-green-700"
                  >
                    Help & Support
                  </button>
                  <button 
                    onClick={() => handleSettingsAction('about')}
                    className="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-green-50 hover:text-green-700"
                  >
                    About
                  </button>
                </div>
              </div>
            )}

            {/* User menu */}
            <div className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-gradient-to-br from-green-400 to-green-500 rounded-full flex items-center justify-center">
                <User className="w-4 h-4 text-white" />
              </div>
              <div className="hidden md:block">
                <p className="text-sm font-medium text-gray-900">Admin User</p>
                <p className="text-xs text-gray-500">Administrator</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default Navigation;
