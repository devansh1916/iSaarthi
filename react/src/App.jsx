import React, { useState } from 'react';
import Navigation from './components/Navigation';
import Dashboard from './components/Dashboard';
import IssueManagement from './components/IssueManagement';
import DepartmentAssignment from './components/DepartmentAssignment';
import PriorityManagement from './components/PriorityManagement';
import Analytics from './components/Analytics';
import './App.css';

function App() {
  const [currentPage, setCurrentPage] = useState('dashboard');

  const renderCurrentPage = () => {
    switch (currentPage) {
      case 'dashboard':
        return <Dashboard />;
      case 'issues':
        return <IssueManagement />;
      case 'assignment':
        return <DepartmentAssignment />;
      case 'priority':
        return <PriorityManagement />;
      case 'analytics':
        return <Analytics />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-green-50">
      <Navigation currentPage={currentPage} onPageChange={setCurrentPage} />
      <main className="lg:ml-64 pt-20 bg-gradient-to-br from-gray-50 to-green-50 min-h-screen">
        <div className="p-6">
          {renderCurrentPage()}
        </div>
      </main>
    </div>
  );
}

export default App;
