import React, { useState } from 'react';
// Assuming your components are in a 'components' sub-folder
import Navigation from './components/Navigation';
import Dashboard from './components/Dashboard';
import FlaggedForReview from './components/FlaggedForReview';
import IssueManagement from './components/IssueManagement';
import Analytics from './components/Analytics';
// Assuming you have a global CSS file
import './App.css';

// A placeholder for the Department Performance page
const DepartmentPerformance = () => {
  return (
    <div>
      <h1 className="text-3xl font-bold text-gray-900">Department Performance</h1>
      <p className="mt-4 text-gray-600">This page is under construction. It will show analytics on department workloads, resolution times, and efficiency.</p>
    </div>
  );
};

function App() {
  const [currentPage, setCurrentPage] = useState('dashboard');

  const handlePageChange = (pageId) => {
    setCurrentPage(pageId);
  };

  // This function now renders the correct component based on the currentPage state
  const renderCurrentPage = () => {
    switch (currentPage) {
      case 'dashboard':
        // Pass the page change handler so the "Needs Review" card can navigate
        return <Dashboard onPageChange={handlePageChange} />;
      case 'flagged':
        return <FlaggedForReview />;
      case 'issues':
        return <IssueManagement />;
      case 'performance':
        return <DepartmentPerformance />;
      case 'analytics':
        return <Analytics />;
      default:
        return <Dashboard onPageChange={handlePageChange} />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-green-50">
      <Navigation currentPage={currentPage} onPageChange={handlePageChange} />
      <main className="lg:ml-64 pt-20 bg-gradient-to-br from-gray-50 to-green-50 min-h-screen">
        <div className="p-6">
          {renderCurrentPage()}
        </div>
      </main>
    </div>
  );
}

export default App;