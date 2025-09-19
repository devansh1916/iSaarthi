import React, { useState, useEffect } from 'react';
import { 
  Filter, 
  Search, 
  SortAsc, 
  SortDesc, 
  Calendar, 
  MapPin, 
  User, 
  Building,
  AlertTriangle,
  Clock,
  CheckCircle,
  XCircle,
  Eye,
  Edit,
  Trash2
} from 'lucide-react';

const IssueManagement = () => {
  const [issues, setIssues] = useState([]);
  const [filteredIssues, setFilteredIssues] = useState([]);
  const [filters, setFilters] = useState({
    search: '',
    status: 'all',
    priority: 'all',
    department: 'all',
    dateRange: 'all',
    assignedTo: 'all'
  });
  const [sortBy, setSortBy] = useState('date');
  const [sortOrder, setSortOrder] = useState('desc');
  const [showFilters, setShowFilters] = useState(false);
  const [selectedIssues, setSelectedIssues] = useState([]);

  // Mock data serves as a fallback
  const mockIssues = [
    {
      id: "mock-1",
      issue: "Pothole on Main Street",
      description: "Large pothole causing traffic issues and vehicle damage",
      location: "Main Street, Downtown",
      status: "Pending",
      priority: "High",
      department: "Public Works",
      reportedBy: "John Doe",
      date: "2024-01-15T10:30:00Z",
      assignedTo: "Road Maintenance Team",
      category: "Infrastructure"
    },
    {
      id: "mock-2",
      issue: "Broken Street Light",
      description: "Street light not working at intersection, safety concern",
      location: "Oak Avenue & 5th Street",
      status: "In Progress",
      priority: "Medium",
      department: "Utilities",
      reportedBy: "Jane Smith",
      date: "2024-01-14T18:45:00Z",
      assignedTo: "Electrical Team",
      category: "Utilities"
    },
    {
      id: "mock-3",
      issue: "Garbage Collection Missed",
      description: "Garbage not collected on scheduled day",
      location: "123 Elm Street",
      status: "Resolved",
      priority: "Low",
      department: "Sanitation",
      reportedBy: "Bob Johnson",
      date: "2024-01-13T08:15:00Z",
      assignedTo: "Waste Management",
      category: "Sanitation"
    }
  ];

  useEffect(() => {
    const fetchIssues = async () => {
      try {
        const response = await fetch('http://localhost:3001/api/issues');
        if (!response.ok) {
          throw new Error('Backend server is not running or responding.');
        }
        const liveIssues = await response.json();
        setIssues([...liveIssues, ...mockIssues]);
      } catch (error) {
        console.error("Failed to fetch issues, falling back to mock data:", error);
        setIssues(mockIssues);
      }
    };
    fetchIssues();
  }, []);


  useEffect(() => {
    let filtered = [...issues];

    if (filters.search) {
      filtered = filtered.filter(issue =>
        (issue.issue || issue.title || '').toLowerCase().includes(filters.search.toLowerCase()) ||
        issue.description.toLowerCase().includes(filters.search.toLowerCase()) ||
        issue.location.toLowerCase().includes(filters.search.toLowerCase()) ||
        (issue.reportedBy || '').toLowerCase().includes(filters.search.toLowerCase())
      );
    }

    if (filters.status !== 'all') {
      filtered = filtered.filter(issue => issue.status.toLowerCase().replace(' ', '-') === filters.status);
    }

    if (filters.priority !== 'all') {
      filtered = filtered.filter(issue => issue.priority.toLowerCase() === filters.priority);
    }

    if (filters.department !== 'all') {
      filtered = filtered.filter(issue => issue.department === filters.department);
    }

    if (filters.dateRange !== 'all') {
      const now = new Date();
      const daysAgo = parseInt(filters.dateRange);
      const cutoffDate = new Date(now.getTime() - (daysAgo * 24 * 60 * 60 * 1000));
      filtered = filtered.filter(issue => new Date(issue.date || issue.reportedAt) >= cutoffDate);
    }

    if (filters.assignedTo !== 'all') {
      filtered = filtered.filter(issue => issue.assignedTo === filters.assignedTo);
    }

    filtered.sort((a, b) => {
      let aValue = a[sortBy];
      let bValue = b[sortBy];

      if (sortBy === 'date') {
        aValue = new Date(a.date || a.reportedAt);
        bValue = new Date(b.date || b.reportedAt);
      }

      if (sortOrder === 'asc') {
        return aValue > bValue ? 1 : -1;
      } else {
        return aValue < bValue ? 1 : -1;
      }
    });

    setFilteredIssues(filtered);
  }, [issues, filters, sortBy, sortOrder]);

  const getStatusIcon = (status) => {
    switch (status) {
      case 'Pending': return <Clock className="w-4 h-4 text-yellow-500" />;
      case 'In Progress': return <AlertTriangle className="w-4 h-4 text-blue-500" />;
      case 'Resolved': return <CheckCircle className="w-4 h-4 text-green-500" />;
      case 'Urgent': return <AlertTriangle className="w-4 h-4 text-red-500" />;
      default: return <XCircle className="w-4 h-4 text-gray-500" />;
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
      case 'Urgent': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getIssueRowBackgroundColor = (priority) => {
    switch (priority) {
      case 'High': return 'bg-red-50 border-l-4 border-red-500';
      case 'Medium': return 'bg-yellow-50 border-l-4 border-yellow-500';
      case 'Low': return 'bg-green-50 border-l-4 border-green-500';
      default: return 'bg-white border-l-4 border-gray-300';
    }
  };

  const handleSelectIssue = (issueId) => {
    setSelectedIssues(prev => 
      prev.includes(issueId) 
        ? prev.filter(id => id !== issueId)
        : [...prev, issueId]
    );
  };

  const handleSelectAll = () => {
    if (selectedIssues.length === filteredIssues.length) {
      setSelectedIssues([]);
    } else {
      setSelectedIssues(filteredIssues.map(issue => issue.id));
    }
  };

  const handleBulkAction = (action) => {
    console.log(`Bulk action: ${action} on issues:`, selectedIssues);
    setSelectedIssues([]);
  };

  const departments = [...new Set(issues.map(issue => issue.department))];
  const assignees = [...new Set(issues.map(issue => issue.assignedTo))].filter(Boolean);

  return (
    <div className="p-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-900">Issue Management</h1>
        <div className="flex items-center space-x-4">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center space-x-2 px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors"
          >
            <Filter className="w-4 h-4" />
            <span>Filters</span>
          </button>
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search issues by title, description, location, or reporter..."
                value={filters.search}
                onChange={(e) => setFilters(prev => ({ ...prev, search: e.target.value }))}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              />
            </div>
          </div>
          <div className="flex gap-2">
            <select
              value={filters.status}
              onChange={(e) => setFilters(prev => ({ ...prev, status: e.target.value }))}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
            >
              <option value="all">All Status</option>
              <option value="pending">Pending</option>
              <option value="in-progress">In Progress</option>
              <option value="resolved">Resolved</option>
              <option value="urgent">Urgent</option>
            </select>
            <select
              value={filters.priority}
              onChange={(e) => setFilters(prev => ({ ...prev, priority: e.target.value }))}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
            >
              <option value="all">All Priorities</option>
              <option value="high">High</option>
              <option value="medium">Medium</option>
              <option value="low">Low</option>
            </select>
          </div>
        </div>

        {showFilters && (
          <div className="mt-6 pt-6 border-t border-gray-200">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Department</label>
                <select
                  value={filters.department}
                  onChange={(e) => setFilters(prev => ({ ...prev, department: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
                  <option value="all">All Departments</option>
                  {departments.map(dept => (
                    <option key={dept} value={dept}>{dept}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Date Range</label>
                <select
                  value={filters.dateRange}
                  onChange={(e) => setFilters(prev => ({ ...prev, dateRange: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
                  <option value="all">All Time</option>
                  <option value="1">Last 24 hours</option>
                  <option value="7">Last 7 days</option>
                  <option value="30">Last 30 days</option>
                  <option value="90">Last 90 days</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Assigned To</label>
                <select
                  value={filters.assignedTo}
                  onChange={(e) => setFilters(prev => ({ ...prev, assignedTo: e.target.value }))}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                >
                  <option value="all">All Assignees</option>
                  {assignees.map(assignee => (
                    <option key={assignee} value={assignee}>{assignee}</option>
                  ))}
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Sort By</label>
                <div className="flex">
                  <select
                    value={sortBy}
                    onChange={(e) => setSortBy(e.target.value)}
                    className="flex-1 px-3 py-2 border border-gray-300 rounded-l-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
                  >
                    <option value="date">Report Date</option>
                    <option value="priority">Priority</option>
                    <option value="status">Status</option>
                    <option value="issue">Title</option>
                    <option value="department">Department</option>
                  </select>
                  <button
                    onClick={() => setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')}
                    className="px-3 py-2 border border-l-0 border-gray-300 rounded-r-lg hover:bg-gray-50"
                  >
                    {sortOrder === 'asc' ? <SortAsc className="w-4 h-4" /> : <SortDesc className="w-4 h-4" />}
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
      {selectedIssues.length > 0 && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div className="flex items-center justify-between">
            <span className="text-sm font-medium text-blue-800">
              {selectedIssues.length} issue(s) selected
            </span>
            <div className="flex space-x-2">
              <button
                onClick={() => handleBulkAction('assign')}
                className="px-3 py-1 bg-green-600 text-white text-sm rounded hover:bg-green-700"
              >
                Assign
              </button>
              <button
                onClick={() => handleBulkAction('priority')}
                className="px-3 py-1 bg-yellow-600 text-white text-sm rounded hover:bg-yellow-700"
              >
                Change Priority
              </button>
              <button
                onClick={() => handleBulkAction('status')}
                className="px-3 py-1 bg-blue-600 text-white text-sm rounded hover:bg-blue-700"
              >
                Update Status
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="bg-white rounded-lg shadow-md border border-gray-200 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left">
                  <input
                    type="checkbox"
                    checked={selectedIssues.length === filteredIssues.length && filteredIssues.length > 0}
                    onChange={handleSelectAll}
                    className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                  />
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Issue
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Priority
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Department
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Assigned To
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Reported
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredIssues.map((issue) => (
                <tr key={issue.id} className={`hover:bg-gray-50 transition-colors duration-200 ${getIssueRowBackgroundColor(issue.priority)}`}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <input
                      type="checkbox"
                      checked={selectedIssues.includes(issue.id)}
                      onChange={() => handleSelectIssue(issue.id)}
                      className="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-start">
                      <div className="flex-shrink-0 mr-3 mt-1">
                        {getStatusIcon(issue.status)}
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="text-sm font-medium text-gray-900 truncate">
                          {issue.issue || issue.title}
                        </p>
                        <p className="text-sm text-gray-500 truncate">
                          {issue.description}
                        </p>
                        <div className="flex items-center mt-1 text-xs text-gray-500">
                          <MapPin className="w-3 h-3 mr-1" />
                          <span className="truncate">{issue.location}</span>
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getStatusColor(issue.status)}`}>
                      {issue.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${getPriorityColor(issue.priority)}`}>
                      {issue.priority}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <div className="flex items-center">
                      <Building className="w-4 h-4 mr-2 text-gray-400" />
                      {issue.department}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    <div className="flex items-center">
                      <User className="w-4 h-4 mr-2 text-gray-400" />
                      {issue.assignedTo}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <div className="flex items-center">
                      <Calendar className="w-4 h-4 mr-2 text-gray-400" />
                      {new Date(issue.date || issue.reportedAt).toLocaleDateString()}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex space-x-2">
                      <button className="text-green-600 hover:text-green-900 p-1 rounded hover:bg-green-100">
                        <Eye className="w-4 h-4" />
                      </button>
                      <button className="text-gray-600 hover:text-gray-900 p-1 rounded hover:bg-gray-100">
                        <Edit className="w-4 h-4" />
                      </button>
                      <button className="text-red-600 hover:text-red-900 p-1 rounded hover:bg-red-100">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <div className="flex items-center justify-between">
        <div className="text-sm text-gray-700">
          Showing {filteredIssues.length} of {issues.length} issues
        </div>
        <div className="flex space-x-2">
          <button className="px-3 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
            Previous
          </button>
          <button className="px-3 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
            Next
          </button>
        </div>
      </div>
    </div>
  );
};

export default IssueManagement;