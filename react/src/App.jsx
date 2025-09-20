import React, { useState, useEffect, useCallback } from 'react';
import Navigation from './components/Navigation.jsx';
import Header from './components/Header.jsx';
import Dashboard from './components/Dashboard.jsx';
import IssueManagement from './components/IssueManagement.jsx';
import FlaggedForReview from './components/FlaggedForReview.jsx';
import Analytics from './components/Analytics.jsx';
import DepartmentAssignment from './components/DepartmentAssignment.jsx';
import PriorityManagement from './components/PriorityManagement.jsx';

const API_URL = 'http://localhost:3001';

function App() {
  const [currentPage, setCurrentPage] = useState('dashboard');
  const [issues, setIssues] = useState([]);
  const [flaggedIssues, setFlaggedIssues] = useState([]);
  const [loading, setLoading] = useState(true);

  // This function fetches fresh data for the entire app from the server.
  // It's wrapped in useCallback to prevent unnecessary re-renders.
  const fetchAllData = useCallback(async () => {
    setLoading(true);
    try {
      // Fetch both active issues and flagged issues simultaneously.
      const [issuesRes, flaggedRes] = await Promise.all([
        fetch(`${API_URL}/api/issues`),
        fetch(`${API_URL}/api/issues/flagged`)
      ]);
      
      if (!issuesRes.ok || !flaggedRes.ok) {
        throw new Error('Network response was not ok');
      }

      const activeIssues = await issuesRes.json();
      const reviewIssues = await flaggedRes.json();
      
      setIssues(activeIssues);
      setFlaggedIssues(reviewIssues);

    } catch (error) {
      console.error("Failed to fetch data from the server:", error);
      // You could set an error state here to display a message to the user
    } finally {
      setLoading(false);
    }
  }, []);

  // Fetch all data when the application first loads.
  useEffect(() => {
    fetchAllData();
  }, [fetchAllData]);

  // This function is passed to IssueManagement to handle resolving issues.
  const handleBulkResolve = async (selectedIssueIds) => {
    console.log("App: Resolving issues:", selectedIssueIds);
    await fetch(`${API_URL}/api/issues/bulk-update`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
            ids: selectedIssueIds, 
            payload: { status: 'Resolved' }
        })
    });
    fetchAllData(); // Re-fetch all data to reflect changes everywhere.
  };

  // This function is passed to IssueManagement to handle flagging issues.
  const handleBulkRejectAndFlag = async (selectedIssueIds) => {
    console.log("App: Rejecting and flagging issues:", selectedIssueIds);
    await fetch(`${API_URL}/api/issues/bulk-update`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
            ids: selectedIssueIds, 
            payload: { flagged: true, flagReason: 'Rejected by Department' }
        })
    });
    fetchAllData(); // Re-fetch all data to reflect changes everywhere.
  };

  // This function is passed to FlaggedForReview to approve an issue, which un-flags it.
  const handleApproveFlagged = async (issueId, newDepartment, newPriority) => {
    console.log("App: Approving flagged issue:", issueId);
     await fetch(`${API_URL}/api/issues/${issueId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
            department: newDepartment,
            priority: newPriority,
            status: 'Pending', // Move it back to the main queue
            flagged: false,   // This is the key change to un-flag it
            flagReason: null
        })
    });
    fetchAllData(); // Re-fetch all data.
  };
  
  // This function is passed to FlaggedForReview to dismiss a flag without taking other action.
  const handleDismissFlag = async (issueId) => {
     console.log("App: Dismissing flagged issue:", issueId);
     await fetch(`${API_URL}/api/issues/${issueId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
            flagged: false, // Simply un-flag it
            flagReason: null
        })
    });
    fetchAllData(); // Re-fetch all data.
  };

  // This function determines which page component to render based on the current state.
  const renderPage = () => {
    switch (currentPage) {
      case 'dashboard':
        // The dashboard needs all issues to calculate correct stats.
        return <Dashboard issues={[...issues, ...flaggedIssues]} loading={loading} />;
      case 'issues':
        return <IssueManagement 
                  issues={issues} 
                  onBulkResolve={handleBulkResolve}
                  onBulkRejectAndFlag={handleBulkRejectAndFlag} 
                  loading={loading} 
                />;
      case 'flagged':
        return <FlaggedForReview 
                  flaggedIssues={flaggedIssues} 
                  onApprove={handleApproveFlagged}
                  onDismiss={handleDismissFlag}
                  loading={loading} 
                />;
      case 'analytics':
        return <Analytics issues={[...issues, ...flaggedIssues]} />;
      // The pages below are still using mock data as per their original design.
      // They can be connected to the server in the future if needed.
      case 'department':
          return <DepartmentAssignment />;
      case 'priority':
          return <PriorityManagement />;
      default:
        return <Dashboard issues={issues} loading={loading} />;
    }
  };

  return (
    <div className="bg-gray-100 min-h-screen font-sans">
      {/* The Sidebar is a fixed element that exists on its own. */}
      <Navigation currentPage={currentPage} onPageChange={setCurrentPage} />

      {/* The main content area is pushed to the right on large screens to avoid the sidebar. */}
      <div className="lg:ml-64 flex flex-col h-screen">
        {/* The Header is now part of the main content flow, at the top. */}
        <Header currentPage={currentPage} />
        
        {/* The current page's content is rendered here and is scrollable if it's too long. */}
        <main className="flex-1 overflow-y-auto p-6">
          {renderPage()}
        </main>
      </div>
    </div>
  );
}

export default App;