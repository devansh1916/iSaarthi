import React from 'react';
import { Search, Bell, User } from 'lucide-react';

// You'll need to define this or pass it as a prop if it's dynamic
const navigationItems = [
    { id: 'dashboard', name: 'Dashboard', description: 'Overview of all issues' },
    { id: 'flagged', name: 'Flagged for Review', description: 'Issues needing manual review' },
    { id: 'issues', name: 'Issue Management', description: 'Filter and sort all issues' },
    { id: 'analytics', name: 'Analytics', description: 'Reports and insights' },
    { id: 'department', name: 'Department Assignment', description: 'Assign issues to departments'},
    { id: 'priority', name: 'Priority Management', description: 'Manage smart priorities'}
];

const Header = ({ currentPage }) => {
  const pageInfo = navigationItems.find(item => item.id === currentPage);

  return (
    <header className="bg-white border-b border-gray-200 px-6 py-4">
      <div className="flex items-center justify-between">
        {/* Page Title */}
        <div className="flex items-center space-x-4">
          <h2 className="text-xl font-semibold text-gray-900">
            {pageInfo?.name || 'Dashboard'}
          </h2>
          <span className="hidden md:block text-sm text-gray-500">
            {pageInfo?.description}
          </span>
        </div>
        
        {/* Header Controls */}
        <div className="flex items-center space-x-4">
          <div className="hidden md:block relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
            <input
              type="text"
              placeholder="Search issues..."
              className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 w-64"
            />
          </div>

          <button className="relative p-2 text-gray-500 hover:text-green-600">
            <Bell className="w-5 h-5" />
            <span className="absolute -top-1 -right-1 w-5 h-5 bg-green-500 text-white text-xs rounded-full flex items-center justify-center">
              5
            </span>
          </button>

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
    </header>
  );
};

export default Header;