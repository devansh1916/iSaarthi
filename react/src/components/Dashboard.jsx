import React, { useState, useEffect } from 'react';
import { 
  AlertTriangle, 
  Clock, 
  CheckCircle, 
  XCircle, 
  MapPin, 
  Users, 
  TrendingUp,
  Filter,
  Search,
  User,
  Building,
  Calendar
} from 'lucide-react';


// Helper to get a consistent and valid date object or null
const getIssueDate = (issue) => {
  // The server now sends a standardized ISO string in the 'timestamp' field for all new issues.
  if (issue.timestamp) {
    const d = new Date(issue.timestamp);
    if (!isNaN(d.getTime())) return d;
  }
  // Fallback for mock data
  if (issue.reportedAt) {
    const d = new Date(issue.reportedAt);
    if (!isNaN(d.getTime())) return d;
  }
  // Fallback for very old records that only had a 'date' field
  if (issue.date) {
    const d = new Date(issue.date);
    if (!isNaN(d.getTime())) return d;
  }
  return null; // Return null for invalid or missing dates
};


const IssueDetailModal = ({ issue, onClose }) => {
  if (!issue) return null;

  const getPriorityColor = (priority) => {
    switch (priority.toLowerCase()) {
      case 'high': return 'bg-red-100 text-red-800';
      case 'medium': return 'bg-yellow-100 text-yellow-800';
      case 'low': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (status) => {
    switch (status.toLowerCase()) {
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'in-progress': return 'bg-blue-100 text-blue-800';
      case 'resolved': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const issueDate = getIssueDate(issue);

  return (
    <div className="fixed inset-0 bg-[rgba(0,0,0,0.6)] backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="p-6 border-b border-gray-200 sticky top-0 bg-white">
          <div className="flex justify-between items-start">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">{issue.title || issue.issue}</h2>
              <div className="flex items-center space-x-2 mt-2">
                <span className={`px-3 py-1 text-xs font-semibold rounded-full ${getPriorityColor(issue.priority)}`}>
                  {issue.priority.toUpperCase()}
                </span>
                <span className={`px-3 py-1 text-xs font-semibold rounded-full ${getStatusColor(issue.status)}`}>
                  {issue.status.replace('-', ' ').toUpperCase()}
                </span>
              </div>
            </div>
            <button onClick={onClose} className="p-2 text-gray-400 hover:text-gray-600">
              <XCircle className="w-6 h-6" />
            </button>
          </div>
        </div>
        <div className="p-6 space-y-6">
          <div>
            <h3 className="text-sm font-medium text-gray-500 mb-1">Description</h3>
            <p className="text-gray-800">{issue.description}</p>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h3 className="text-sm font-medium text-gray-500 mb-2">Details</h3>
              <div className="space-y-3">
                <div className="flex items-center text-sm">
                  <MapPin className="w-4 h-4 mr-3 text-gray-400" />
                  <span className="text-gray-800">{issue.location}</span>
                </div>
                <div className="flex items-center text-sm">
                  <Building className="w-4 h-4 mr-3 text-gray-400" />
                  <span className="text-gray-800">{issue.department}</span>
                </div>
              </div>
            </div>
            <div>
              <h3 className="text-sm font-medium text-gray-500 mb-2">Reporting Info</h3>
              <div className="space-y-3">
                <div className="flex items-center text-sm">
                  <User className="w-4 h-4 mr-3 text-gray-400" />
                  <span className="text-gray-800">Reported by {issue.reportedBy}</span>
                </div>
                <div className="flex items-center text-sm">
                  <Calendar className="w-4 h-4 mr-3 text-gray-400" />
                  <span className="text-gray-800">
                    On {issueDate ? issueDate.toLocaleString() : 'No date available'}
                  </span>
                </div>
              </div>
            </div>
          </div>
          {issue.assignedTo && (
            <div>
              <h3 className="text-sm font-medium text-gray-500 mb-1">Assigned To</h3>
              <p className="text-gray-800">{issue.assignedTo}</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};


const Dashboard = () => {
  const [issues, setIssues] = useState([]);
  const [stats, setStats] = useState({
    total: 0,
    pending: 0,
    inProgress: 0,
    resolved: 0,
    urgent: 0
  });
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedIssue, setSelectedIssue] = useState(null);

  useEffect(() => {
    const fetchIssues = async () => {
      try {
        setLoading(true);
        setError('');
        const response = await fetch('http://localhost:3001/api/issues');
        if (!response.ok) {
          throw new Error('Backend server is not running or responding.');
        }
        const liveIssues = await response.json();
        
        // The server now sends perfectly sorted data, so no client-side sorting is needed.
        setIssues(liveIssues);

      } catch (err) {
        console.error("Failed to fetch issues:", err);
        setError('Could not connect to the server. Please ensure the backend is running.');
        setIssues([]);
      } finally {
        setLoading(false);
      }
    };

    fetchIssues();
  }, []);

  useEffect(() => {
    if (issues.length > 0) {
      const total = issues.length;
      const pending = issues.filter(issue => issue.status.toLowerCase() === 'pending').length;
      const inProgress = issues.filter(issue => issue.status.toLowerCase() === 'in-progress').length;
      const resolved = issues.filter(issue => issue.status.toLowerCase() === 'resolved').length;
      const urgent = issues.filter(issue => issue.priority.toLowerCase() === 'high').length;
      setStats({ total, pending, inProgress, resolved, urgent });
    } else {
        setStats({ total: 0, pending: 0, inProgress: 0, resolved: 0, urgent: 0 });
    }
  }, [issues]);


  const filteredIssues = issues.filter(issue => {
    const title = issue.title || issue.issue || '';
    const reportedBy = issue.reportedBy || '';
    const searchLower = searchTerm.toLowerCase();

    const matchesSearch = title.toLowerCase().includes(searchLower) ||
                         issue.description.toLowerCase().includes(searchLower) ||
                         issue.location.toLowerCase().includes(searchLower) ||
                         reportedBy.toLowerCase().includes(searchLower);

    const matchesStatus = statusFilter === 'all' || issue.status.toLowerCase().replace(/\s+/g, '-') === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusIcon = (status) => {
    switch (status.toLowerCase()) {
      case 'pending': return <Clock className="w-4 h-4 text-yellow-500" />;
      case 'in-progress': return <AlertTriangle className="w-4 h-4 text-blue-500" />;
      case 'resolved': return <CheckCircle className="w-4 h-4 text-green-500" />;
      default: return <XCircle className="w-4 h-4 text-red-500" />;
    }
  };

  const getPriorityColor = (priority) => {
    switch (priority.toLowerCase()) {
      case 'high': return 'bg-red-100 text-red-800';
      case 'medium': return 'bg-yellow-100 text-yellow-800';
      case 'low': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (status) => {
    switch (status.toLowerCase()) {
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'in-progress': return 'bg-blue-100 text-blue-800';
      case 'resolved': return 'bg-green-100 text-green-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getIssueBackgroundColor = (priority) => {
    switch (priority.toLowerCase()) {
      case 'high': return 'bg-gradient-to-r from-red-100 to-red-200 border-l-4 border-red-500';
      case 'medium': return 'bg-gradient-to-r from-yellow-100 to-yellow-200 border-l-4 border-yellow-500';
      case 'low': return 'bg-gradient-to-r from-green-100 to-green-200 border-l-4 border-green-500';
      default: return 'bg-gradient-to-r from-gray-100 to-gray-200 border-l-4 border-gray-500';
    }
  };

  const handleViewDetails = (issue) => {
    setSelectedIssue(issue);
  };

  const handleCloseModal = () => {
    setSelectedIssue(null);
  };

  return (
    <>
      <IssueDetailModal issue={selectedIssue} onClose={handleCloseModal} />
      <div className="space-y-6">
        {/* Header */}
        <div className="flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">Civic Issues Dashboard</h1>
          <div className="flex items-center space-x-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search by name, location, user..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
            >
              <option value="all">All Status</option>
              <option value="pending">Pending</option>
              <option value="in-progress">In Progress</option>
              <option value="resolved">Resolved</option>
            </select>
          </div>
        </div>

        {error && <div className="p-4 text-center text-red-700 bg-red-100 rounded-lg">{error}</div>}

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
          <div className="bg-gradient-to-br from-white to-green-50 p-6 rounded-lg shadow-md border border-green-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Total Issues</p>
                <p className="text-2xl font-bold text-gray-900">{loading ? '...' : stats.total}</p>
              </div>
              <AlertTriangle className="w-8 h-8 text-green-500" />
            </div>
          </div>

          <div className="bg-gradient-to-br from-white to-yellow-50 p-6 rounded-lg shadow-md border border-yellow-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Pending</p>
                <p className="text-2xl font-bold text-yellow-600">{loading ? '...' : stats.pending}</p>
              </div>
              <Clock className="w-8 h-8 text-yellow-500" />
            </div>
          </div>

          <div className="bg-gradient-to-br from-white to-blue-50 p-6 rounded-lg shadow-md border border-blue-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">In Progress</p>
                <p className="text-2xl font-bold text-blue-600">{loading ? '...' : stats.inProgress}</p>
              </div>
              <AlertTriangle className="w-8 h-8 text-blue-500" />
            </div>
          </div>

          <div className="bg-gradient-to-br from-white to-green-50 p-6 rounded-lg shadow-md border border-green-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Resolved</p>
                <p className="text-2xl font-bold text-green-600">{loading ? '...' : stats.resolved}</p>
              </div>
              <CheckCircle className="w-8 h-8 text-green-500" />
            </div>
          </div>

          <div className="bg-gradient-to-br from-white to-red-50 p-6 rounded-lg shadow-md border border-red-200">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Urgent</p>
                <p className="text-2xl font-bold text-red-600">{loading ? '...' : stats.urgent}</p>
              </div>
              <AlertTriangle className="w-8 h-8 text-red-500" />
            </div>
          </div>
        </div>

        {/* Issues List */}
        <div className="bg-white rounded-lg shadow-md border border-gray-200">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-lg font-semibold text-gray-900">Recent Issues</h2>
          </div>
          <div className="space-y-4 p-4">
            {loading ? (
              <div className="text-center py-8 text-gray-500">Loading live issues...</div>
            ) : filteredIssues.map((issue) => {
                const issueDate = getIssueDate(issue);
                return (
                  <div key={issue.id} className={`p-6 rounded-lg shadow-sm transition-all duration-200 hover:shadow-lg hover:scale-[1.01] ${getIssueBackgroundColor(issue.priority)}`}>
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="flex items-center space-x-3 mb-2">
                          {getStatusIcon(issue.status)}
                          <h3 className="text-lg font-medium text-gray-900">{issue.title || issue.issue}</h3>
                          <span className={`px-2 py-1 text-xs font-medium rounded-full ${getPriorityColor(issue.priority)}`}>
                            {issue.priority.toUpperCase()}
                          </span>
                          <span className={`px-2 py-1 text-xs font-medium rounded-full ${getStatusColor(issue.status)}`}>
                            {issue.status.replace('-', ' ').toUpperCase()}
                          </span>
                        </div>
                        <p className="text-gray-600 mb-2">{issue.description}</p>
                        <div className="flex items-center space-x-4 text-sm text-gray-500">
                          <div className="flex items-center space-x-1">
                            <MapPin className="w-4 h-4" />
                            <span>{issue.location}</span>
                          </div>
                          <div className="flex items-center space-x-1">
                            <Users className="w-4 h-4" />
                            <span>{issue.department}</span>
                          </div>
                          <span>Reported by {issue.reportedBy}</span>
                          {/* UPDATED: Display both date and time */}
                          <span>{issueDate ? issueDate.toLocaleString() : 'No date available'}</span>
                        </div>
                      </div>
                      <div className="ml-4">
                        <button 
                          onClick={() => handleViewDetails(issue)}
                          className="px-4 py-2 bg-green-200 text-green-800 font-semibold rounded-lg hover:bg-green-300 transition-colors shadow-sm">
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