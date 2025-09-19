import React, { useState, useEffect } from 'react';
import { 
  AlertTriangle, 
  Check, 
  Edit, 
  X, 
  Search, 
  MapPin, 
  Calendar,
  ShieldQuestion,
  ThumbsUp,
  ThumbsDown,
  Building
} from 'lucide-react';


const ModifyAssignmentModal = ({ issue, onClose, onConfirm }) => {
  if (!issue) return null;

  const [department, setDepartment] = useState(issue.suggestedDepartment);
  const [priority, setPriority] = useState(issue.suggestedPriority);

  const handleConfirm = () => {
    onConfirm(issue.id, department, priority);
    onClose();
  };

  return (
    <div className="fixed inset-0 bg-[rgba(0,0,0,0.6)] backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-lg shadow-2xl w-full max-w-lg">
        <div className="p-6 border-b border-gray-200">
          <div className="flex justify-between items-start">
            <div>
              <h2 className="text-xl font-bold text-gray-900">Modify & Assign</h2>
              <p className="text-sm text-gray-500">{issue.title}</p>
            </div>
            <button onClick={onClose} className="p-2 text-gray-400 hover:text-gray-600">
              <X className="w-6 h-6" />
            </button>
          </div>
        </div>
        <div className="p-6 space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Department</label>
            <select
              value={department}
              onChange={(e) => setDepartment(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
            >
              <option>Public Works</option>
              <option>Utilities</option>
              <option>Sanitation</option>
              <option>Emergency Services</option>
              <option>Parks & Recreation</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Priority</label>
            <select
              value={priority}
              onChange={(e) => setPriority(e.target.value)}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
            >
              <option>Low</option>
              <option>Medium</option>
              <option>High</option>
              <option>Urgent</option>
            </select>
          </div>
        </div>
        <div className="p-6 bg-gray-50 border-t border-gray-200 flex justify-end space-x-3">
          <button onClick={onClose} className="px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-100">
            Cancel
          </button>
          <button onClick={handleConfirm} className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
            Confirm Assignment
          </button>
        </div>
      </div>
    </div>
  );
};


const FlaggedForReview = () => {
  const [flaggedIssues, setFlaggedIssues] = useState([]);
  const [filteredIssues, setFilteredIssues] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterReason, setFilterReason] = useState('all');
  const [editingIssue, setEditingIssue] = useState(null);

  const mockFlaggedIssues = [
    {
      id: "flag-1",
      title: "Unusual Noise from Power Station",
      description: "A citizen reported a loud humming noise from the main power station, which is not normal.",
      location: "North Power Station",
      reportedBy: "Alice Johnson",
      reportedAt: "2025-09-18T14:00:00Z",
      flagReason: "Low Confidence Score",
      suggestedDepartment: "Utilities",
      suggestedPriority: "Medium",
      confidence: 65,
    },
    {
      id: "flag-2",
      title: "Potential Gas Leak Reported",
      description: "A strong smell of gas was reported near the city library. Multiple reports came in.",
      location: "City Library",
      reportedBy: "System",
      reportedAt: "2025-09-19T01:15:00Z",
      flagReason: "Urgent Keyword Detected",
      suggestedDepartment: "Emergency Services",
      suggestedPriority: "Urgent",
      confidence: 98,
    },
    {
      id: "flag-3",
      title: "Fallen Tree Branch",
      description: "A large tree branch has fallen and is blocking a sidewalk.",
      location: "Maple Avenue Park",
      reportedBy: "Bob Williams",
      reportedAt: "2025-09-18T09:30:00Z",
      flagReason: "Assignment Rejected",
      rejectionReason: "Team at capacity",
      suggestedDepartment: "Parks & Recreation",
      suggestedPriority: "Low",
      confidence: 91,
    }
  ];

  useEffect(() => {

    const fetchFlaggedIssues = async () => {
      setLoading(true);
      try {
        const response = await fetch('http://localhost:3001/api/flagged-issues'); // Using a live API endpoint
        if (!response.ok) {
          throw new Error('Backend server is not running or responding.');
        }
        const liveFlaggedIssues = await response.json();
        setFlaggedIssues(liveFlaggedIssues);
      } catch (error) {
        console.error("Failed to fetch flagged issues:", error);
        setFlaggedIssues(mockFlaggedIssues);
      } finally {
        setLoading(false);
      }
    };
    fetchFlaggedIssues();
  }, []);
  
  useEffect(() => {
    let filtered = [...flaggedIssues];
    if (searchTerm) {
      filtered = filtered.filter(issue =>
        issue.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        issue.description.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    if (filterReason !== 'all') {
      filtered = filtered.filter(issue => issue.flagReason.replace(/\s+/g, '-') === filterReason);
    }
    setFilteredIssues(filtered);
  }, [flaggedIssues, searchTerm, filterReason]);


  const getFlagReasonStyle = (reason) => {
    switch (reason) {
      case 'Low Confidence Score':
        return { icon: <ShieldQuestion className="w-4 h-4 text-yellow-600" />, color: 'bg-yellow-100 text-yellow-800' };
      case 'Urgent Keyword Detected':
        return { icon: <AlertTriangle className="w-4 h-4 text-red-600" />, color: 'bg-red-100 text-red-800' };
      case 'Assignment Rejected':
        return { icon: <ThumbsDown className="w-4 h-4 text-orange-600" />, color: 'bg-orange-100 text-orange-800' };
      default:
        return { icon: <AlertTriangle className="w-4 h-4 text-gray-600" />, color: 'bg-gray-100 text-gray-800' };
    }
  };

  const handleAction = (issueId, action) => {
    console.log(`Action: ${action} for issue: ${issueId}`);
    setFlaggedIssues(prev => prev.filter(issue => issue.id !== issueId));
  };
  
  const handleModifyConfirm = (issueId, department, priority) => {
    console.log(`Confirmed assignment for issue ${issueId}: Dept - ${department}, Priority - ${priority}`);
    setFlaggedIssues(prev => prev.filter(issue => issue.id !== issueId));
  }

  if (loading) {
    return <div className="p-6 text-center">Loading issues for review...</div>;
  }

  return (
    <>
      <ModifyAssignmentModal issue={editingIssue} onClose={() => setEditingIssue(null)} onConfirm={handleModifyConfirm} />
      <div className="p-6 space-y-6">
        <div className="flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">Flagged for Review</h1>
          <span className="bg-yellow-100 text-yellow-800 text-sm font-medium px-3 py-1 rounded-full">
            {filteredIssues.length} item(s) need attention
          </span>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-200">
          <div className="flex flex-col lg:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input
                type="text"
                placeholder="Search flagged issues by title or description..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500"
              />
            </div>
            <select
              value={filterReason}
              onChange={(e) => setFilterReason(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500"
            >
              <option value="all">All Flag Reasons</option>
              <option value="Low-Confidence-Score">Low Confidence</option>
              <option value="Urgent-Keyword-Detected">Urgent Keyword</option>
              <option value="Assignment-Rejected">Assignment Rejected</option>
            </select>
          </div>
        </div>
        
        <div className="space-y-4">
          {filteredIssues.map((issue) => {
            const flagStyle = getFlagReasonStyle(issue.flagReason);
            return (
              <div key={issue.id} className="bg-white rounded-lg shadow-md border border-gray-200 overflow-hidden">
                <div className={`p-4 border-b border-gray-200 flex items-center justify-between ${flagStyle.color.split(' ')[0]}`}>
                  <div className="flex items-center space-x-2">
                    {flagStyle.icon}
                    <span className={`text-sm font-semibold ${flagStyle.color.split(' ')[1]}`}>{issue.flagReason}</span>
                  </div>
                  <span className={`text-xs font-medium ${flagStyle.color.split(' ')[1]}`}>Confidence: {issue.confidence}%</span>
                </div>
                <div className="p-6">
                  <h3 className="text-lg font-semibold text-gray-900">{issue.title}</h3>
                  <p className="text-sm text-gray-600 mt-1">{issue.description}</p>
                  <div className="flex items-center space-x-4 text-xs text-gray-500 mt-3">
                    <div className="flex items-center"><MapPin className="w-3 h-3 mr-1" />{issue.location}</div>
                    <div className="flex items-center"><Calendar className="w-3 h-3 mr-1" />{new Date(issue.reportedAt).toLocaleDateString()}</div>
                  </div>
                  <div className="mt-4 p-4 bg-gray-50 rounded-lg border border-gray-200">
                    <p className="text-sm font-medium text-gray-800">AI Suggestion:</p>
                    <div className="flex items-center space-x-4 mt-2">
                      <div className="flex items-center text-sm">
                        <Building className="w-4 h-4 mr-2 text-gray-500" />
                        Assign to <strong className="ml-1">{issue.suggestedDepartment}</strong>
                      </div>
                      <div className="flex items-center text-sm">
                        <AlertTriangle className="w-4 h-4 mr-2 text-gray-500" />
                        Set priority to <strong className="ml-1">{issue.suggestedPriority}</strong>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="p-4 bg-gray-50 border-t border-gray-200 flex items-center justify-end space-x-3">
                  <button onClick={() => handleAction(issue.id, 'dismiss')} className="flex items-center space-x-2 px-4 py-2 text-sm bg-gray-200 text-gray-800 rounded-lg hover:bg-gray-300">
                    <X className="w-4 h-4" />
                    <span>Dismiss</span>
                  </button>
                  <button onClick={() => setEditingIssue(issue)} className="flex items-center space-x-2 px-4 py-2 text-sm bg-yellow-400 text-yellow-900 rounded-lg hover:bg-yellow-500">
                    <Edit className="w-4 h-4" />
                    <span>Modify & Assign</span>
                  </button>
                  <button onClick={() => handleAction(issue.id, 'approve')} className="flex items-center space-x-2 px-4 py-2 text-sm bg-green-500 text-white rounded-lg hover:bg-green-600">
                    <Check className="w-4 h-4" />
                    <span>Approve Suggestion</span>
                  </button>
                </div>
              </div>
            );
          })}
        </div>

      </div>
    </>
  );
};

export default FlaggedForReview;
