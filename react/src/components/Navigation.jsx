import React, { useState } from 'react';
import { 
  Home, 
  Filter, 
  Building, 
  BarChart3, 
  Settings, 
  Menu, 
  X,
  User,
  LogOut,
  ShieldQuestion,
  Star,
  Users as DepartmentIcon
} from 'lucide-react';

const Navigation = ({ currentPage, onPageChange }) => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const navigationItems = [
    { id: 'dashboard', name: 'Dashboard', icon: Home, description: 'Overview of all issues' },
    { id: 'flagged', name: 'Flagged for Review', icon: ShieldQuestion, description: 'Issues needing manual review' },
    { id: 'issues', name: 'Issue Management', icon: Filter, description: 'Filter and sort all issues' },
    { id: 'analytics', name: 'Analytics', icon: BarChart3, description: 'Reports and insights' }
  ];

  const handlePageChange = (pageId) => {
    onPageChange(pageId);
    setIsMobileMenuOpen(false);
  };

  return (
    <>
      {/* Mobile Menu Button */}
      <div className="lg:hidden fixed top-4 left-4 z-[60]">
        <button
          onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          className="p-2 bg-white rounded-lg shadow-md border border-gray-200"
        >
          {isMobileMenuOpen ? <X className="w-6 h-6 text-gray-800" /> : <Menu className="w-6 h-6 text-gray-800" />}
        </button>
      </div>

      {/* Overlay for mobile */}
      {isMobileMenuOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-50 lg:hidden"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* --- SIDEBAR --- */}
      <aside 
        className={`fixed top-0 left-0 h-full w-64 shadow-lg z-50 transform transition-transform duration-300 ease-in-out flex flex-col
          ${isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'}
          lg:translate-x-0`
        }
        style={{ 
          backgroundColor: '#55AD9B',
          borderRight: '1px solid #4a9a8a'
        }}
      >
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

        <nav className="flex-1 p-4 space-y-2">
          {navigationItems.map((item) => {
            const isActive = currentPage === item.id;
            return (
              <button
                key={item.id}
                onClick={() => handlePageChange(item.id)}
                className={`
                  w-full flex items-center space-x-3 px-4 py-3 rounded-lg text-left transition-colors group
                  ${isActive 
                    ? 'bg-white border shadow-md' 
                    : 'bg-white hover:shadow-sm'
                  }
                `}
                style={isActive ? {
                  color: '#55AD9B',
                  borderColor: '#55AD9B'
                } : {
                  color: '#55AD9B',
                  backgroundColor: 'white'
                }}
              >
                <item.icon 
                  className="w-5 h-5 flex-shrink-0" 
                  style={{ color: '#55AD9B' }}
                />
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium truncate">{item.name}</p>
                  <p 
                    className="text-xs truncate"
                    style={{ color: '#77c4b7' }}
                  >
                    {item.description}
                  </p>
                </div>
              </button>
            );
          })}
        </nav>

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
          
          <div className="flex">
            {/* The Settings button has been removed */}
            <button className="flex-1 flex items-center justify-center space-x-2 px-3 py-2 bg-red-400 text-white rounded-lg hover:bg-red-500 transition-colors">
              <LogOut className="w-4 h-4" />
              <span className="text-xs">Logout</span>
            </button>
          </div>
        </div>
      </aside>
    </>
  );
};

export default Navigation;