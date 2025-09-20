import React, { useState, useMemo } from 'react';
import { 
  AlertTriangle, Clock, CheckCircle, Search, MapPin, 
  Users
} from 'lucide-react';
import IssueDetailModal from './IssueDetailModal';

const getIssueDate = (issue) => {
  if (!issue) return null;
  const fields = ['timestamp', 'reportedAt', 'date'];
  for (const field of fields) {
    if (issue[field]) {
      const d = new Date(issue[field]);
      if (!isNaN(d.getTime())) return d;
    }
  }
  return null; 
};

const Dashboard = ({ issues, loading }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [selectedIssue, setSelectedIssue] = useState(null);

  const stats = useMemo(() => {
    const total = issues.length;
    const pending = issues.filter(issue => issue.status === 'Pending').length;
    const inProgress = issues.filter(issue => issue.status === 'In Progress').length;
    const resolved = issues.filter(issue => issue.status === 'Resolved').length;
    const urgent = issues.filter(issue => issue.priority === 'High').length; // Assuming 'High' priority is urgent for stats
    return { total, pending, inProgress, resolved, urgent };
  }, [issues]);

  const filteredIssues = useMemo(() => {
    return issues
      .filter(issue => {
        const title = issue.title || issue.issue || '';
        const reportedBy = issue.reportedBy || '';
        const searchLower = searchTerm.toLowerCase();

        const matchesSearch = title.toLowerCase().includes(searchLower) ||
                             (issue.description || '').toLowerCase().includes(searchLower) ||
                             (issue.location || '').toLowerCase().includes(searchLower) ||
                             reportedBy.toLowerCase().includes(searchLower);

        const matchesStatus = statusFilter === 'all' || (issue.status || '').toLowerCase().replace(/\s+/g, '-') === statusFilter;
        return matchesSearch && matchesStatus;
      })
      .sort((a, b) => new Date(b.date || b.reportedAt || b.timestamp) - new Date(a.date || a.reportedAt || a.timestamp)); // Sort by most recent
  }, [issues, searchTerm, statusFilter]);

  const getStatusIcon = (status) => {
    switch (status) {
      case 'Pending': return <Clock className="w-4 h-4 text-yellow-500" />;
      case 'In Progress': return <AlertTriangle className="w-4 h-4 text-blue-500" />;
      case 'Resolved': return <CheckCircle className="w-4 h-4 text-green-500" />;
      default: return null;
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority) {
      case 'High': return 'bg-red-100 text-red-800';
      case 'Medium': return 'bg-yellow-100 text-yellow-800';
      case 'Low': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'Pending': return 'bg-yellow-100 text-yellow-800';
      case 'In Progress': return 'bg-blue-100 text-blue-800';
      case 'Resolved': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getIssueBackgroundColor = (priority) => {
    switch (priority) {
      case 'High': return 'bg-red-50 border-l-4 border-red-500';
      case 'Medium': return 'bg-yellow-50 border-l-4 border-yellow-500';
      case 'Low': return 'bg-green-50 border-l-4 border-green-500';
      default: return 'bg-gray-50 border-l-4 border-gray-400';
    }
  };

  return (
    <>
      <IssueDetailModal issue={selectedIssue} onClose={() => setSelectedIssue(null)} />
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">Total Issues</p>
            <p className="text-2xl font-bold text-gray-900">{loading ? '...' : stats.total}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">Pending</p>
            <p className="text-2xl font-bold text-yellow-600">{loading ? '...' : stats.pending}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">In Progress</p>
            <p className="text-2xl font-bold text-blue-600">{loading ? '...' : stats.inProgress}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">Resolved</p>
            <p className="text-2xl font-bold text-green-600">{loading ? '...' : stats.resolved}</p>
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
            <p className="text-sm font-medium text-gray-600">Urgent (High Priority)</p>
            <p className="text-2xl font-bold text-red-600">{loading ? '...' : stats.urgent}</p>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Recent Issues</h2>
          </div>
          <div className="space-y-4 p-4">
            {loading ? (
              <div className="text-center py-8 text-gray-500">Loading issues...</div>
            ) : filteredIssues.length === 0 ? (
                <div className="text-center py-8 text-gray-500">No issues to display.</div>
            ) : filteredIssues.slice(0, 5).map((issue) => { // Show top 5 recent issues
                const issueDate = getIssueDate(issue);
                return (
                  <div key={issue.id} className={`p-4 rounded-lg shadow-sm transition-all duration-200 hover:shadow-md ${getIssueBackgroundColor(issue.priority)}`}>
                    <div className="flex items-start justify-between">
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center space-x-3 mb-2">
                          {getStatusIcon(issue.status)}
                          <h3 className="text-base font-medium text-gray-900 truncate">{issue.title || issue.issue}</h3>
                          <span className={`px-2 py-1 text-xs font-medium rounded-full ${getPriorityColor(issue.priority)}`}>{issue.priority}</span>
                          <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(issue.status)}`}>{issue.status}</span>
                        </div>
                        
                        {/* --- UPDATED: Added 'truncate' to shorten the description --- */}
                        <p className="text-sm text-gray-600 mb-2 truncate">{issue.description}</p>
                        
                        <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-sm text-gray-500">
                          <div className="flex items-center space-x-1"><MapPin className="w-4 h-4" /><span>{issue.readableLocation || issue.location}</span></div>
                          <div className="flex items-center space-x-1"><Users className="w-4 h-4" /><span>{issue.department}</span></div>
                          <span>Reported by {issue.reportedBy}</span>
                          <span>{issueDate ? issueDate.toLocaleDateString() : 'No date'}</span>
                        </div>
                      </div>
                      <div className="ml-4 flex-shrink-0">
                        <button 
                          onClick={() => setSelectedIssue(issue)}
                          className="px-3 py-2 bg-white text-gray-700 font-semibold rounded-lg border border-gray-300 hover:bg-gray-50 transition-colors shadow-sm text-sm">
                          View Details
                        </button>
                      </div>
                    </div>
                  </div>
                )
            })}
          </div>
        </div>
      </div>
    </>
  );
};

export default Dashboard;