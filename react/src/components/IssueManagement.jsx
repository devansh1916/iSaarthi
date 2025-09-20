import React, { useState, useMemo } from 'react';
import { 
  Filter, Search, SortAsc, SortDesc, Calendar, MapPin, Building,
  AlertTriangle, Clock, CheckCircle, Eye, Edit, ShieldCheck, ShieldAlert
} from 'lucide-react';
import IssueDetailModal from './IssueDetailModal';

const ISSUES_PER_PAGE = 10;

const IssueManagement = ({ issues, onBulkResolve, onBulkRejectAndFlag, loading }) => {
  const [filters, setFilters] = useState({ search: '', status: 'all', priority: 'all' });
  const [sortBy, setSortBy] = useState('date');
  const [sortOrder, setSortOrder] = useState('desc');
  const [showFilters, setShowFilters] = useState(false);
  const [selectedIssues, setSelectedIssues] = useState([]);
  const [viewingIssue, setViewingIssue] = useState(null);
  const [currentPage, setCurrentPage] = useState(1);
  
  const filteredAndSortedIssues = useMemo(() => {
    let filtered = [...issues];
    if (filters.search) {
      filtered = filtered.filter(issue =>
        (issue.issue || issue.title || '').toLowerCase().includes(filters.search.toLowerCase()) ||
        (issue.description || '').toLowerCase().includes(filters.search.toLowerCase())
      );
    }
    if (filters.status !== 'all') filtered = filtered.filter(issue => issue.status.toLowerCase().replace(' ', '-') === filters.status);
    if (filters.priority !== 'all') filtered = filtered.filter(issue => issue.priority.toLowerCase() === filters.priority);
    
    filtered.sort((a, b) => {
        let aValue = a[sortBy];
        let bValue = b[sortBy];
        if (sortBy === 'date') {
            aValue = new Date(a.date || a.reportedAt || a.timestamp);
            bValue = new Date(b.date || b.reportedAt || b.timestamp);
        }
        if (sortOrder === 'asc') return aValue > bValue ? 1 : -1;
        return aValue < bValue ? 1 : -1;
    });
    return filtered;
  }, [issues, filters, sortBy, sortOrder]);

  const totalPages = Math.ceil(filteredAndSortedIssues.length / ISSUES_PER_PAGE);
  const paginatedIssues = useMemo(() => {
    const startIndex = (currentPage - 1) * ISSUES_PER_PAGE;
    return filteredAndSortedIssues.slice(startIndex, startIndex + ISSUES_PER_PAGE);
  }, [filteredAndSortedIssues, currentPage]);

  const handleBulkResolve = () => {
    onBulkResolve(selectedIssues);
    setSelectedIssues([]);
  };

  const handleBulkRejectAndFlag = () => {
    onBulkRejectAndFlag(selectedIssues);
    setSelectedIssues([]);
  };
  
  const handleSelectIssue = (issueId) => {
    setSelectedIssues(prev => prev.includes(issueId) ? prev.filter(id => id !== issueId) : [...prev, issueId]);
  };

  const handleSelectAll = () => {
    const allOnPageSelected = paginatedIssues.every(issue => selectedIssues.includes(issue.id));
    if (allOnPageSelected) {
      setSelectedIssues(prev => prev.filter(id => !paginatedIssues.map(issue => issue.id).includes(id)));
    } else {
      const newSelected = new Set([...selectedIssues, ...paginatedIssues.map(issue => issue.id)]);
      setSelectedIssues(Array.from(newSelected));
    }
  };

  // Helper styling functions (no changes)
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
  const getIssueRowBackgroundColor = (priority) => {
    switch (priority) {
      case 'High': return 'bg-red-100 border-l-4 border-red-600';
      case 'Medium': return 'bg-yellow-100 border-l-4 border-yellow-600';
      case 'Low': return 'bg-green-100 border-l-4 border-green-600';
      default: return 'bg-gray-100 border-l-4 border-gray-400';
    }
  };

  return (
    <>
      <IssueDetailModal issue={viewingIssue} onClose={() => setViewingIssue(null)} />
      <div className="space-y-6">
        <div className="flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">Issue Management</h1>
          <button onClick={() => setShowFilters(!showFilters)} className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200">
            <Filter className="w-4 h-4" /> <span>Filters</span>
          </button>
        </div>
        
        {selectedIssues.length > 0 && (
          <div className="bg-blue-100 border border-blue-300 rounded-lg p-4 flex items-center justify-between shadow-sm">
            <span className="text-sm font-medium text-blue-800">{selectedIssues.length} issue(s) selected</span>
            <div className="flex space-x-3">
              <button onClick={handleBulkRejectAndFlag} className="flex items-center space-x-2 px-4 py-2 bg-yellow-500 text-white text-sm font-semibold rounded-lg hover:bg-yellow-600 transition-colors shadow-md">
                <ShieldAlert className="w-4 h-4" />
                <span>Reject & Flag</span>
              </button>
              <button onClick={handleBulkResolve} className="flex items-center space-x-2 px-4 py-2 bg-green-600 text-white text-sm font-semibold rounded-lg hover:bg-green-700 transition-colors shadow-md">
                <ShieldCheck className="w-4 h-4" />
                <span>Mark as Resolved</span>
              </button>
            </div>
          </div>
        )}

        <div className="bg-white rounded-lg shadow-md border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left w-12"><input type="checkbox" onChange={handleSelectAll} checked={paginatedIssues.length > 0 && paginatedIssues.every(issue => selectedIssues.includes(issue.id))} className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"/></th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Issue</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Priority</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Department</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Reported</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {loading ? (
                  <tr><td colSpan="7" className="text-center py-8 text-gray-500">Loading issues...</td></tr>
                ) : paginatedIssues.length === 0 ? (
                  <tr><td colSpan="7" className="text-center py-8 text-gray-500">No active issues found.</td></tr>
                ) : paginatedIssues.map((issue) => (
                  <tr key={issue.id} className={`transition-colors duration-200 ${getIssueRowBackgroundColor(issue.priority)}`}>
                    <td className="px-6 py-4"><input type="checkbox" checked={selectedIssues.includes(issue.id)} onChange={() => handleSelectIssue(issue.id)} className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"/></td>
                    <td className="px-6 py-4 max-w-sm"> {/* Added max-w-sm to constrain width */}
                      <p className="text-sm font-medium text-gray-900 truncate">{issue.issue || issue.title}</p>
                      
                      {/* --- UPDATED: Added 'truncate' class to shorten the description --- */}
                      <p className="text-sm text-gray-500 truncate">{issue.description}</p>
                      
                      <div className="flex items-center mt-1 text-xs text-gray-500">
                        <MapPin className="w-3 h-3 mr-1 flex-shrink-0" />
                        <span className="truncate">{issue.readableLocation || issue.location}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4"><span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(issue.status)}`}>{issue.status}</span></td>
                    <td className="px-6 py-4"><span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(issue.priority)}`}>{issue.priority}</span></td>
                    <td className="px-6 py-4 text-sm text-gray-900"><div className="flex items-center"><Building className="w-4 h-4 mr-2 text-gray-400" />{issue.department}</div></td>
                    <td className="px-6 py-4 text-sm text-gray-500">{new Date(issue.date || issue.reportedAt || issue.timestamp).toLocaleDateString()}</td>
                    <td className="px-6 py-4 text-sm font-medium">
                      <div className="flex space-x-2">
                        <button onClick={() => setViewingIssue(issue)} className="text-green-600 hover:text-green-900 p-1 rounded hover:bg-green-100"><Eye className="w-4 h-4" /></button>
                        <button className="text-gray-600 hover:text-gray-900 p-1 rounded hover:bg-gray-100"><Edit className="w-4 h-4" /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="flex items-center justify-between">
          <div className="text-sm text-gray-700">Showing {paginatedIssues.length} of {filteredAndSortedIssues.length} issues</div>
          <div className="flex space-x-2">
            <button onClick={() => setCurrentPage(p => Math.max(1, p - 1))} disabled={currentPage === 1} className="px-3 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50">Previous</button>
            <span className="text-sm font-medium text-gray-700">Page {currentPage} of {totalPages || 1}</span>
            <button onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))} disabled={currentPage === totalPages || totalPages === 0} className="px-3 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50">Next</button>
          </div>
        </div>
      </div>
    </>
  );
};

export default IssueManagement;