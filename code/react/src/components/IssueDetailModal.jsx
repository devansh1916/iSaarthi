import React from 'react';
import { XCircle, MapPin, Building, User, Calendar } from 'lucide-react';

// Helper function to get a date object from various possible fields
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

// Helper functions for styling based on issue properties
const getPriorityColor = (priority = '') => {
  switch (priority.toLowerCase()) {
    case 'high': return 'bg-red-100 text-red-800';
    case 'medium': return 'bg-yellow-100 text-yellow-800';
    case 'low': return 'bg-green-100 text-green-800';
    default: return 'bg-gray-100 text-gray-800';
  }
};

const getStatusColor = (status = '') => {
  switch (status.toLowerCase().replace(' ', '-')) {
    case 'pending': return 'bg-yellow-100 text-yellow-800';
    case 'in-progress': return 'bg-blue-100 text-blue-800';
    case 'resolved': return 'bg-green-100 text-green-800';
    default: return 'bg-gray-100 text-gray-800';
  }
};

const IssueDetailModal = ({ issue, onClose }) => {
  if (!issue) return null;

  const issueDate = getIssueDate(issue);
  const priority = issue.priority || 'N/A';
  const status = issue.status || 'N/A';

  return (
    <div className="fixed inset-0 bg-[rgba(0,0,0,0.6)] backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <div className="p-6 border-b border-gray-200 sticky top-0 bg-white">
          <div className="flex justify-between items-start">
            <div>
              <h2 className="text-2xl font-bold text-gray-900">{issue.title || issue.issue}</h2>
              <div className="flex items-center space-x-2 mt-2">
                <span className={`px-3 py-1 text-xs font-semibold rounded-full ${getPriorityColor(priority)}`}>
                  {priority.toUpperCase()}
                </span>
                <span className={`px-3 py-1 text-xs font-semibold rounded-full ${getStatusColor(status)}`}>
                  {status.replace('-', ' ').toUpperCase()}
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

export default IssueDetailModal;